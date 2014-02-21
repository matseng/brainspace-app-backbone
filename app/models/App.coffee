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
    deltaX: 0  #ie panX
    deltaY: 0  #ie panY
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
    if(event.which == 1)  #the mouse is down and being dragged!!!
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
        vent.trigger('pan')
      else
        window.selectedNode.modelView = null
        window.mouse.down = false
  )

  $(document.body).on("mouseup", (event) ->
    console.log("mouseup is #{window.mouse.x}, #{window.mouse.y}")
    window.selectedNode.modelView = null
    window.mouse.down = false
  )

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

  # Mousetrap.bind('command+v', (e) ->
  #   console.log('Mousetrap working with command-v')
  #   debugger
  #   vent.trigger('pasteImage', e)  #e becomes an arguement that gets passed to callback contained in listeners
  # )

  pasteHandler = (e) ->
    vent.trigger('pasteImage', e)  #e becomes an arguement that gets passed to callback contained in listeners
    
  window.addEventListener("paste", pasteHandler)

  class App.Models.Node extends Backbone.Model
    defaults: {
    username: "Mikey Testing T"
    text: 'Hack Reactor'
    top: null
    left: null
    imageData: null
    imageSize: null
    imageSizeValue: null
    }
    validate: (attrs) ->
      if attrs.text is null
        "Text requires a valid string"
    setAbsCoordinates: (x, y) ->  # (x, y) are in relative coordinate system
      zoom = window.Transform.zoom
      distFromCenterX = x - window.Transform.centerX
      distFromCenterY = y - window.Transform.centerY
      transX = window.Transform.centerX + (x - window.Transform.centerX) * 1 / zoom
      transY = window.Transform.centerY + (y - window.Transform.centerY) * 1 / zoom
      @.set({"left": transX - window.Transform.deltaX})
      @.set({"top": transY - window.Transform.deltaY})

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
      'mousedown': 'mouseDownSelectNode'
      'mouseenter': 'mouseenter'
      'mouseleave': 'mouseleave'
      'change .imageSizeSelector': 'changeImageSize'
      'dblclick' : 'zoomToNode'
    }

    zoomToNode: () ->
      window.Transform.zoom = zoom = 1
      window.Transform.deltaX = $('body').width() / 2 - @.model.get('left') - @.$el.find('.text').width() / zoom / 2
      window.Transform.deltaY = $('body').height() / 2 - @.model.get('top') - @.$el.find('.text').height() / zoom / 2
      vent.trigger('zoom')

    changeImageSize: (e) ->
      #if this nodeView has an image...
      $image = @.$el.find('img')
      if $image  #check if image exists, then proceed with changes
        newSize = parseInt(e.target.value)  #e.g. 50 from select drop down menu
        width = ''
        height = ''
        if newSize == 100
          $image.css('width', "")  # set width and height to default image size
          $image.css('height', "")
        else
          $image.css('width', "")  # set width and height to default image size (ie. absolute value)
          $image.css('height', "")
          width = Math.round($image.width() * Math.sqrt(newSize) / 10)
          height = Math.round($image.height() * Math.sqrt(newSize) / 10)
          $image.css('width', width)  # set width and height to default image size
          $image.css('height', height)
        @.model.set(
          {imageSize: {'width': width, 'height', height}
          imageSizeValue: newSize
          })
      # debugger

    mouseenter: () ->
      @.$el.find('.nodeMenu').css('visibility', 'visible')
      if @.$el.find('img').length  #show image size selector only if the node contains an image
        @.$el.find('.imageSizeContainer').css('visibility', 'visible')

    mouseleave: () ->
      @.$el.find('.nodeMenu').css('visibility', 'hidden')
      @.$el.find('.imageSizeContainer').css('visibility', 'hidden')


    mouseDownSelectNode: (e) ->
      #e.preventDefault()
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
      if confirm("Confirm delete")
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
      transX = window.Transform.centerX + distFromCenterX * zoom
      transY = window.Transform.centerY + distFromCenterY * zoom
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
        newPromptText = @.model.get('text')
        @.$el.find('.text').text(newPromptText)
        debugger
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
      if @.model.get('imageData') != null
        imageTag = '<img class="pastedImage"/>'
        $image = $(imageTag).attr('src', @.model.get('imageData'))
        @.$el.append($image)
        if @.model.get('imageSize')
          $image.css(@.model.get('imageSize'))
        if @.model.get('imageSizeValue')
          @.$el.find(".imageSizeSelector").val(@.model.get('imageSizeValue'))
      @.zoom()
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
      nodeView.render()  #Bug requires second render invocation

    removeOne: (model, coll, opt) ->
      $("#" + model.id).detach()

  class App.Views.AddNode extends Backbone.View
    #el: '#addNote'
    el: '#inputContainer'
    
    events: {
      'submit #addNote': 'submit'
      'change #file-upload': 'fileUpload'

    }

    initialize: () ->
      vent.on('pasteImage', @.pasteImage, @)
      
    fileUpload: (evt) ->
      that = @
      f = evt.target.files[0]
      reader = new FileReader()
      reader.onload = ((theFile) -> 
        return (e) -> 
          filePayload = e.target.result
          node = new App.Models.Node({
            text: "no text yet"
            username: 'me of course'
            imageData: filePayload
          })
          that.collection.add(node)
      )(f)
      reader.readAsDataURL(f)

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
    pasteImage: (event) ->
      that = @
      clipboardData = event.clipboardData  ||  event.originalEvent.clipboardData
      items = clipboardData.items;
      i = 0
      while i < items.length
        console.log(i)
        if items[i].type.indexOf("image") == 0 
          blob = items[i].getAsFile()
          i = items.length
        i++
      # load image if there is a pasted image:      
      if (blob != null)
        reader = new FileReader();
        reader.onloadend = (e) -> 
          filePayload = e.target.result
          node = new App.Models.Node({
            text: "Title goes here"
            username: 'me of course'
            imageData: filePayload
          })
          node.setAbsCoordinates($('body').width() / 2, $('body').height() / 2)
          that.collection.add(node)
        reader.readAsDataURL(blob)

 

  #nodeView = new App.Views.Node({model: new App.Model.Node()})
  collectionNodes = new App.Collections.Nodes()
  addNodeView = new App.Views.AddNode({collection: collectionNodes})
  nodeCollectionView = new App.Views.NodesCollection({collection: collectionNodes})
  $(".nodes").append(nodeCollectionView.render().el)

  # $(document).ready(() ->
  #   debugger
  #   $(".nodes").append(nodeCollectionView.render().el)

)()

