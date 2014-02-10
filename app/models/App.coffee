(() ->
  window.App = {
    Models: {}
    Collections: {}
    Views: {}
  }

  window.template = (id) ->
    _.template($("#" + id).html())

  class App.Models.Node extends Backbone.Model

  class App.Views.Node extends Backbone.View
    tagName: 'li'

    render: () ->
      @.$el.html( @.model.get('name'))
      @

  class App.Collections.Nodes extends Backbone.Collection
    model: App.Models.Node

  class App.Views.NodesCollection extends Backbone.View
    tagName: 'div'
    render: () ->
      @.collection.each(@.addOne, @)
      @
    addOne: (node) ->
      nodeView = new App.Views.Node({model: node})
      @.$el.append(nodeView.render().el)

  nodeCollection = new App.Collections.Nodes([
    {
    name: "Mike T"
    text: "Hello World"
    },
    {
    name: "Peter T"
    text: "What's up?"
    },
    {
    name: "Jossy"
    text: "Hey bros"
    }
  ])

  #nodeView = new App.Views.Node({model: node})
  nodeCollectionView = new App.Views.NodesCollection({collection: nodeCollection})
  $(".nodes").append(nodeCollectionView.render().el)

  # $(document).ready(() ->
  #   debugger
  #   $(".nodes").append(nodeCollectionView.render().el)

)()

