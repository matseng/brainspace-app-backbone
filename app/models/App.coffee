(() ->
  window.App = {
    Models: {}
    Collections: {}
    Views: {}
    selectedNode: null
  }

  window.template = (id) ->
    _.template($("#" + id).html())

  $(document.body).mousemove( (event) -> 
    event.preventDefault()
    if(window.App.selectedNode)
      selectedNode = window.App.selectedNode
      #console.log(selectedNode)
      selectedNode.set({top: event.pageY})
      selectedNode.set({left: event.pageX})
  )

  $(document.body).on("mouseup", (event) -> 
    #console.log("mouseup... up and away: " + window.App.selectedNode.toJSON());
    window.App.selectedNode = null;
  )

  document.onkeydown = checkKey
  checkKey = (e) ->
    console.log("Event is: " + e.keyCode)
    e = e || window.event
    if e.keyCode == 38
      console.log("up arrow")
    else if e.keyCode == 40
      console.log("down arrow")
    else if e.keyCode == 37
      console.log("left arrow")
    else if e.keyCode == 39
      console.log("right arrow")

  


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
      @.model.on('change', @.render, @)
      @.model.on('destroy', @.remove, @)
      #@.model.on('mousedown', @.mouseDownSelectNode, @)

    events: {
      'click .edit': 'editNode'
      'click .delete': 'deleteNode'
      'mousedown span': 'mouseDownSelectNode'
    }

    mouseDownSelectNode: (e) ->
      e.preventDefault()
      window.App.selectedNode = @.model

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
      debugger
      @.$el.remove()

    render: () ->
      x = @.model.get("left")
      y = @.model.get('top')
      position = {
        top: y + "px"
        left: x + "px"
      }
      
      template = @.template(@.model.toJSON())
      @.$el.html(template)

      @.$el.css('position', 'absolute')
      @.$el.css(position)
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

    render: () ->
      @.collection.each(@.addOne, @)
      @
    
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

