(() ->
  window.App = {
    Models: {}
    Collections: {}
    Views: {}
  }

  window.template = (id) ->
    _.template($("#" + id).html())

  #class App.Models.Node extends Backbone.Model
  class App.Models.Node extends Backbone.Firebase.Model
    firebase: 'https://resplendent-fire-9007.firebaseio.com/mynode'
    validate: (attrs) ->
      if attrs.text is null
        "Text requires a valid string"

  class App.Views.Node extends Backbone.View
    tagName: 'li'

    template: template('nodeTemplate')

    initialize: () ->
      @.model.on('change', @.render, @)
      @.model.on('destroy', @.remove, @)

    events: {
      'click .edit': 'editNode'
      'click .delete': 'deleteNode'
    }

    editNode: () ->
      newText = prompt("Edit the text:", @.model.get('text'))
      if newText is null
        return
      @.model.set('text', newText)

    deleteNode: () ->
      @.model.destroy()

    remove: () ->
      @.$el.remove()

    render: () ->
      #debugger;
      template = @.template(@.model.toJSON())
      @.$el.html(template)
      @

  #class App.Collections.Nodes extends Backbone.Collection
  class App.Collections.Nodes extends Backbone.Firebase.Collection
    model: App.Models.Node
    firebase: new Firebase('https://resplendent-fire-9007.firebaseio.com/')

  class App.Views.NodesCollection extends Backbone.View
    tagName: 'div'

    initialize: () ->
      @.collection.on('add', @.addOne, @)

    render: () ->
      @.collection.each(@.addOne, @)
      @
    
    addOne: (node) ->
      #console.log(node.toJSON())
      nodeView = new App.Views.Node({model: node})
      @.$el.prepend(nodeView.render().el)

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
        text: text || ""
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
  collectionView = new App.Collections.Nodes()
  addNodeView = new App.Views.AddNode({collection: collectionView})
  nodeCollectionView = new App.Views.NodesCollection({collection: collectionView})
  $(".nodes").append(nodeCollectionView.render().el)

  # $(document).ready(() ->
  #   debugger
  #   $(".nodes").append(nodeCollectionView.render().el)

)()

