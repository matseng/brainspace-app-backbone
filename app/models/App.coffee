(() ->
  window.App = {
    Models: {}
    Collections: {}
    Views: {}
    #selectedNode: null
  }
  window.selectedNode = {
    modelView: null
    offsetX: 0
    offsetY: 0
  }
  window.Transform = {
    deltaX: 0
    deltaY: 0
    zoom: 1.0
    centerX: 0
    centerY: 0
  }
  window.mouse = {
    down: false
    x: 0
    y: 0
  }

  vent = _.extend({}, Backbone.Events)

  window.template = (id) ->
    _.template($("#" + id).html())

  $(document.body).mousemove( (event) -> 
    event.preventDefault()
    #console.log("Is modelView null: " + window.selectedNode.modelView)
    if(window.selectedNode.modelView)
      selectedNodeView = window.selectedNode.modelView
      selectedNodeView.setAbsCoordinates(event.pageX - window.selectedNode.offsetX, event.pageY - window.selectedNode.offsetY)
    else if window.mouse.down
      panX = window.mouse.x - event.pageX
      panY = window.mouse.y - event.pageY
      window.Transform.deltaX -= panX * 1 / window.Transform.zoom
      window.Transform.deltaY -= panY * 1 / window.Transform.zoom
      window.mouse.x = event.pageX
      window.mouse.y = event.pageY
      console.log("Change is relative coordinates is #{window.Transform.deltaX}, #{window.Transform.deltaX}")
      vent.trigger('pan')
    else
      window.selectedNode.modelView = null
      window.mouse.down = false
  )

  $(document.body).on("mouseup", (event) -> 
    window.selectedNode.modelView = null
    window.mouse.down = false
  )

  #drag to pan screen (2 helpers)

  #1 of 2: check if a node is NOT selected
  #mousedown for current xy
  $(document.body).on("mousedown", (e) ->
    if !window.selectedNode.modelView
      window.mouse.down = true
      window.mouse.x = e.pageX
      window.mouse.y = e.pageY
      console.log("mousedown is #{window.mouse.x}, #{window.mouse.y}")
  )

  checkKey = (e) ->
    e || e.preventDefault()
    e = e || window.event
    console.log("Event is: " + e.keyCode)
    console.log("Active element is: " + document.activeElement.tagName)
    if document.activeElement.parentNode.tagName != "FORM"
      if e.keyCode == 38
        window.Transform.deltaY += 10 * 1 / window.Transform.zoom
        vent.trigger('pan')
        console.log("up arrow " + window.Transform.deltaY)
      else if e.keyCode == 40
        window.Transform.deltaY -= 10 * 1 / window.Transform.zoom
        vent.trigger('pan')
        console.log("down arrow " + window.Transform.deltaY)
      else if e.keyCode == 37
        window.Transform.deltaX += 10 * 1/ window.Transform.zoom
        vent.trigger('pan')
        console.log("left arrow " + window.Transform.deltaX)
      else if e.keyCode == 39
        window.Transform.deltaX -= 10 * 1 / window.Transform.zoom
        vent.trigger('pan')
        console.log("right arrow " + window.Transform.deltaX)
      else if e.keyCode == 73  #In
        window.Transform.centerX = $('body').width() / 2
        window.Transform.centerY = $('body').height() / 2
        #console.log("Center (x,y) = (#{centerX}, #{centerY})")
        window.Transform.zoom *= 1.5
        vent.trigger('zoom')
        console.log(window.Transform.zoom)
      else if e.keyCode == 79  #Out
        window.Transform.centerX = $('body').width() / 2
        window.Transform.centerY = $('body').height() / 2
        #console.log("Center (x,y) = (#{centerX}, #{centerY})")
        window.Transform.zoom *= 0.67
        vent.trigger('zoom')
        console.log(window.Transform.zoom)
    else

  document.onkeydown = checkKey

  class App.Models.Node extends Backbone.Model
    defaults: {
    username: "Mikey Testing T"
    text: 'Hack Reactor'
    top: null
    left: null
    }
    validate: (attrs) ->
      if attrs.text is null
        "Text requires a valid string"

  class App.Views.Node extends Backbone.View
    tagName: 'li'

    template: template('nodeTemplate')

    initialize: () ->
      @.model.on('change', @.update, @)
      @.model.on('destroy', @.remove, @)
      vent.on('pan', @.zoom, @)
      vent.on('zoom', @.zoom, @)

    events: {
      'click .edit': 'editNode'
      'click .delete': 'deleteNode'
      'mousedown span': 'mouseDownSelectNode'
      'mouseenter': 'mouseenter'
      'mouseleave': 'mouseleave'
    }

    mouseenter: () ->
      @.$el.find('.nodeMenu').css('visibility', 'visible')

    mouseleave: () ->
      @.$el.find('.nodeMenu').css('visibility', 'hidden')

    mouseDownSelectNode: (e) ->
      e.preventDefault()
      nodePositionX = @.$el.position().left #parseInt(@.$el.css('left')) || 
      nodePositionY = @.$el.position().top #parseInt(@.$el.css('top')) || 
      offsetX = event.pageX - nodePositionX
      offsetY = event.pageY - nodePositionY
      window.selectedNode = {
        modelView: @
        offsetX: offsetX  #parseInt(offsetX)
        offsetY: offsetY  #parseInt(offsetY)
      }

    editNode: () ->
      newText = prompt("Edit the text:", @.model.get('text'))
      if newText is null
        return

      currentNode = @.model
      currentNode.set({'text': newText})

    deleteNode: () ->
      #@.model.destroy()  #this destroy methods throws an error!!!
      #@.$el.detach()  #as below, this is a workaround, but it doesn't sync changes to other users
      @.model.collection.remove(@.model)  #destroy method is not working well with firebase

    remove: () ->
      @.$el.remove()

    zoom: () ->
      x = @.model.get("left") + @.$el.width() / 2 + window.Transform.deltaX  #absolute coordinate
      y = @.model.get('top') + @.$el.height() / 2 + window.Transform.deltaY  #absolute coordinate
      zoom = window.Transform.zoom
      distFromCenterX = x - window.Transform.centerX
      distFromCenterY = y - window.Transform.centerY
      transX = window.Transform.centerX + (x - window.Transform.centerX) * zoom
      transY = window.Transform.centerY + (y - window.Transform.centerY) * zoom
      @.$el.css('transform': "scale(#{zoom})")
      @.$el.css('left': transX - @.$el.width() / 2)
      @.$el.css('top': transY - @.$el.height() / 2)
      
    setAbsCoordinates: (x, y) ->  # (x, y) are in relative coordinate system
      zoom = window.Transform.zoom
      distFromCenterX = x - window.Transform.centerX
      distFromCenterY = y - window.Transform.centerY
      transX = window.Transform.centerX + (x - window.Transform.centerX) * 1 / zoom
      transY = window.Transform.centerY + (y - window.Transform.centerY) * 1 / zoom
      @.model.set({"left": transX - window.Transform.deltaX})
      @.model.set({"top": transY - window.Transform.deltaY})

    update: () ->
      #template = @.template(@.model.toJSON())
      #@.$el.html(template)
      #@.$el.css('position', 'absolute')
      if(@.model.changedAttributes().text)
        template = @.template(@.model.toJSON())
        @.$el.html(template)
      else
        @.zoom()

    render: () ->
      
      template = @.template(@.model.toJSON())
      @.$el.html(template)
      @.$el.css('position', 'absolute')
      x = @.model.get("left")
      y = @.model.get('top')
      @.$el.css('left', x)
      @.$el.css('top', y)
      @

  #class App.Collections.Nodes extends Backbone.Collection
  class App.Collections.Nodes extends Backbone.Firebase.Collection
    model: App.Models.Node
    firebase: new Firebase('https://resplendent-fire-9007.firebaseio.com/')

  class App.Views.NodesCollection extends Backbone.View
    tagName: 'div'

    initialize: () ->
      @.collection.on('add', @.addOne, @)
      @.collection.on('remove', @.removeOne, @)
      # vent.on('newTransform', @.render, @)

    rerender: () ->
      @.collection.each( (node) -> 
        #debugger
        node.render()
      , @)

    render: () ->
      @.collection.each(@.addOne, @)
      @  #returns this view
    
    addOne: (node) ->
      #console.log(node.toJSON())
      nodeView = new App.Views.Node({model: node})
      #debugger
      nodeView.$el.attr("id", node.id)
      @.$el.prepend(nodeView.render().el)

    removeOne: (model, coll, opt) ->
      #debugger
      $("#" + model.id).detach()

  class App.Views.AddNode extends Backbone.View
    el: '#addNote'
    
    events: {
      'submit': 'submit'
    }

    #initialize: () ->
      #console.log(@.el.innerHTML)
    
    submit: (e) ->
      e.preventDefault()
      text = $(e.currentTarget).find('textarea[name=text]').val()
      text = text.replace(/\n/g, '<br>')
      username = $(e.currentTarget).find('input[name=username]').val()
      node = new App.Models.Node({
        text: text || "empty"
        username: username || 'anonymous'
      })
      @.collection.add(node)
      #vent.trigger('zoom')

  # nodeCollection = new App.Collections.Nodes([
  #   {
  #   username: "Mike T"
  #   text: "Hello World"
  #   }
  # ])

  #nodeView = new App.Views.Node({model: new App.Model.Node()})
  collectionNodes = new App.Collections.Nodes()
  addNodeView = new App.Views.AddNode({collection: collectionNodes})
  nodeCollectionView = new App.Views.NodesCollection({collection: collectionNodes})
  $(".nodes").append(nodeCollectionView.render().el)

  # $(document).ready(() ->
  #   debugger
  #   $(".nodes").append(nodeCollectionView.render().el)

)()

