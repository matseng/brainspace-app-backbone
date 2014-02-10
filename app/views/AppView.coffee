class window.AppView extends Backbone.View  #var AppView = Backbone.View.extend({});
  tagName: "li"
  
  #template: _.template "<%= name %> (<%=age %>)"
  template: _.template "<%= name %> (<%= school %>)"
  

  className: 'person'
  id: 'personId'

  initialize: ->
    #console.log("#{@.model.get('name')}, hi there")
    @.render()

  render: ->
    #@.$el.html(@.model.get('name') + ' age: ' + @.model.get 'age')
    @.template @.model.toJSON()  #fills in the attributes

person = new App.Models.Person()
window.perView = new AppView({model: person})