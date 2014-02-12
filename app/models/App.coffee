(() ->
  window.App = {
    Models: {}
    Collections: {}
    Views: {}
    #selectedNode: null
  }
  window.selectedNode = {
    model: null
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

  vent = _.extend({}, Backbone.Events)

  window.template = (id) ->
    _.template($("#" + id).html())

  $(document.body).mousemove( (event) -> 
    event.preventDefault()
    if(window.selectedNode.model)
      selectedNode = window.selectedNode.model
      selectedNode.set({top: event.pageY - window.selectedNode.offsetY})
      selectedNode.set({left: event.pageX - window.selectedNode.offsetX})
  )

  $(document.body).on("mouseup", (event) -> 
    #console.log("mouseup... up and away: " + window.App.selectedNode.toJSON());
    window.selectedNode.model = null;
  )

  checkKey = (e) ->
    e || e.preventDefault()
    e = e || window.event
    console.log("Event is: " + e.keyCode)
    if e.keyCode == 38
      window.Transform.deltaY += 10 * window.Transform.zoom
      vent.trigger('translate')
      console.log("up arrow " + window.Transform.deltaY)
    else if e.keyCode == 40
      window.Transform.deltaY -= 10 * window.Transform.zoom
      vent.trigger('translate')
      console.log("down arrow " + window.Transform.deltaY)
    else if e.keyCode == 37
      window.Transform.deltaX += 10 * window.Transform.zoom
      vent.trigger('translate')
      console.log("left arrow " + window.Transform.deltaX)
    else if e.keyCode == 39
      window.Transform.deltaX -= 10 * window.Transform.zoom
      vent.trigger('translate')
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

  document.onkeydown = checkKey

  class App.Models.Node extends Backbone.Model
  #class App.Models.Node extends Backbone.Firebase.Model
    #firebase: 'https://resplendent-fire-9007.firebaseio.com/myNode'
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
      #@.model.on('mousedown', @.mouseDownSelectNode, @)
      vent.on('translate', @.translate, @)
      vent.on('zoom', @.zoom, @)

    events: {
      'click .edit': 'editNode'
      'click .delete': 'deleteNode'
      'mousedown span': 'mouseDownSelectNode'
      'mouseenter': 'mouseenter'
      'mouseleave': 'mouseleave'
    }

    mouseenter: () ->
      #@.$el.find('.nodeMenu').fadeIn('fast')
      @.$el.find('.nodeMenu').css('visibility', 'visible')

    mouseleave: () ->
      @.$el.find('.nodeMenu').css('visibility', 'hidden')

    mouseDownSelectNode: (e) ->
      e.preventDefault()
      #offsetX = event.pageX - @.model.get('left')
      nodePositionX = parseInt(@.$el.css('left')) || @.$el.position().left
      nodePositionY = parseInt(@.$el.css('top')) || @.$el.position().top
      
      offsetX = event.pageX - nodePositionX
      offsetY = event.pageY - nodePositionY
      #debugger
      window.selectedNode = {
        model: @.model
        offsetX: parseInt(offsetX)
        offsetY: parseInt(offsetY)
      }
      #debugger

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
      x = @.model.get("left") + @.$el.width() / 2 + window.Transform.deltaX #absolute coordinate
      #x = @.model.get("left")  #absolute coordinate
      y = @.model.get('top') + @.$el.height() / 2 + window.Transform.deltaY #absolute coordinate
      #y = @.model.get('top') #absolute coordinate
      zoom = window.Transform.zoom
      distFromCenterX = x - window.Transform.centerX
      distFromCenterY = y - window.Transform.centerY
      transX = window.Transform.centerX + (x - window.Transform.centerX) * zoom
      transY = window.Transform.centerY + (y - window.Transform.centerY) * zoom
      @.$el.css('transform': "scale(#{zoom})")
      @.$el.css('left': transX - @.$el.width() / 2)
      @.$el.css('top': transY - @.$el.height() / 2)
      
    translate: () ->
      x = @.model.get("left") + @.$el.width() / 2 + window.Transform.deltaX #absolute coordinate
      #x = @.model.get("left")  #absolute coordinate
      y = @.model.get('top') + @.$el.height() / 2 + window.Transform.deltaY #absolute coordinate
      #y = @.model.get('top') #absolute coordinate
      zoom = window.Transform.zoom
      distFromCenterX = x - window.Transform.centerX
      distFromCenterY = y - window.Transform.centerY
      transX = window.Transform.centerX + (x - window.Transform.centerX) * zoom
      transY = window.Transform.centerY + (y - window.Transform.centerY) * zoom
      @.$el.css('transform': "scale(#{zoom})")
      @.$el.css('left': transX - @.$el.width() / 2)
      @.$el.css('top': transY - @.$el.height() / 2)

    translate2: () ->
      #debugger
      x = @.model.get("left")
      y = @.model.get('top')
      # x = @.$el.position().left
      # y = @.$el.position().top
      zoom = window.Transform.zoom
      deltaX = window.Transform.deltaX  #input from key left or right
      deltaY = window.Transform.deltaY  #input form key up or down
      position = {
        left: (x + deltaX) * zoom + "px"
        top: (y + deltaY) * zoom + "px"
      }
      @.$el.css('position', 'absolute')
      @.$el.css(position)
      @

    update: () ->
      #template = @.template(@.model.toJSON())
      #@.$el.html(template)
      #@.$el.css('position', 'absolute')
      if(@.model.changedAttributes().text)
        template = @.template(@.model.toJSON())
        @.$el.html(template)
      else
        x = @.model.get("left")
        y = @.model.get('top')
        @.$el.css('left', x)
        @.$el.css('top', y)
        @

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
      text = $(e.currentTarget).find('input[name=text]').val()
      #console.log(text)
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

