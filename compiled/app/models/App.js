// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function() {
    var addNodeView, checkKey, collectionNodes, nodeCollectionView, vent;
    window.App = {
      Models: {},
      Collections: {},
      Views: {},
      selectedNode: null
    };
    window.Transform = {
      deltaX: 0,
      deltaY: 0,
      zoom: 2
    };
    vent = _.extend({}, Backbone.Events);
    window.template = function(id) {
      return _.template($("#" + id).html());
    };
    $(document.body).mousemove(function(event) {
      var selectedNode;
      event.preventDefault();
      if (window.App.selectedNode) {
        selectedNode = window.App.selectedNode;
        selectedNode.set({
          top: event.pageY
        });
        return selectedNode.set({
          left: event.pageX
        });
      }
    });
    $(document.body).on("mouseup", function(event) {
      return window.App.selectedNode = null;
    });
    checkKey = function(e) {
      console.log("Event is: " + e.keyCode);
      e = e || window.event;
      if (e.keyCode === 38) {
        window.Transform.deltaY += 10;
        vent.trigger('newTransform');
        return console.log("up arrow " + window.Transform.deltaY);
      } else if (e.keyCode === 40) {
        window.Transform.deltaY -= 10;
        vent.trigger('newTransform');
        return console.log("down arrow " + window.Transform.deltaY);
      } else if (e.keyCode === 37) {
        window.Transform.deltaX += 10;
        vent.trigger('newTransform');
        return console.log("left arrow " + window.Transform.deltaX);
      } else if (e.keyCode === 39) {
        window.Transform.deltaX -= 10;
        vent.trigger('newTransform');
        return console.log("right arrow " + window.Transform.deltaX);
      }
    };
    document.onkeydown = checkKey;
    App.Models.Node = (function(_super) {
      __extends(Node, _super);

      function Node() {
        return Node.__super__.constructor.apply(this, arguments);
      }

      Node.prototype.defaults = {
        username: "Mikey Testing T",
        text: 'Hack Reactor',
        top: null,
        left: null
      };

      Node.prototype.validate = function(attrs) {
        if (attrs.text === null) {
          return "Text requires a valid string";
        }
      };

      return Node;

    })(Backbone.Model);
    App.Views.Node = (function(_super) {
      __extends(Node, _super);

      function Node() {
        return Node.__super__.constructor.apply(this, arguments);
      }

      Node.prototype.tagName = 'li';

      Node.prototype.template = template('nodeTemplate');

      Node.prototype.initialize = function() {
        this.model.on('change', this.render, this);
        this.model.on('destroy', this.remove, this);
        return vent.on('newTransform', this.render, this);
      };

      Node.prototype.events = {
        'click .edit': 'editNode',
        'click .delete': 'deleteNode',
        'mousedown span': 'mouseDownSelectNode'
      };

      Node.prototype.mouseDownSelectNode = function(e) {
        e.preventDefault();
        return window.App.selectedNode = this.model;
      };

      Node.prototype.editNode = function() {
        var currentNode, newText;
        newText = prompt("Edit the text:", this.model.get('text'));
        if (newText === null) {
          return;
        }
        currentNode = this.model;
        return currentNode.set({
          'text': newText
        });
      };

      Node.prototype.deleteNode = function() {
        return this.model.collection.remove(this.model);
      };

      Node.prototype.remove = function() {
        debugger;
        return this.$el.remove();
      };

      Node.prototype.render = function() {
        var deltaX, deltaY, position, template, x, y, zoom;
        x = this.model.get("left");
        y = this.model.get('top');
        deltaX = window.Transform.deltaX;
        deltaY = window.Transform.deltaY;
        zoom = window.Transform.zoom;
        position = {
          left: x + deltaX + "px",
          top: y + deltaY + "px"
        };
        template = this.template(this.model.toJSON());
        this.$el.html(template);
        this.$el.css('position', 'absolute');
        this.$el.css(position);
        this.$el.css({
          'transform': "scale(" + zoom + ")"
        });
        return this;
      };

      return Node;

    })(Backbone.View);
    App.Collections.Nodes = (function(_super) {
      __extends(Nodes, _super);

      function Nodes() {
        return Nodes.__super__.constructor.apply(this, arguments);
      }

      Nodes.prototype.model = App.Models.Node;

      Nodes.prototype.firebase = new Firebase('https://resplendent-fire-9007.firebaseio.com/');

      return Nodes;

    })(Backbone.Firebase.Collection);
    App.Views.NodesCollection = (function(_super) {
      __extends(NodesCollection, _super);

      function NodesCollection() {
        return NodesCollection.__super__.constructor.apply(this, arguments);
      }

      NodesCollection.prototype.tagName = 'div';

      NodesCollection.prototype.initialize = function() {
        this.collection.on('add', this.addOne, this);
        return this.collection.on('remove', this.removeOne, this);
      };

      NodesCollection.prototype.rerender = function() {
        return this.collection.each(function(node) {
          debugger;
          return node.render();
        }, this);
      };

      NodesCollection.prototype.render = function() {
        this.collection.each(this.addOne, this);
        return this;
      };

      NodesCollection.prototype.addOne = function(node) {
        var nodeView;
        nodeView = new App.Views.Node({
          model: node
        });
        nodeView.$el.attr("id", node.id);
        return this.$el.prepend(nodeView.render().el);
      };

      NodesCollection.prototype.removeOne = function(model, coll, opt) {
        return $("#" + model.id).detach();
      };

      return NodesCollection;

    })(Backbone.View);
    App.Views.AddNode = (function(_super) {
      __extends(AddNode, _super);

      function AddNode() {
        return AddNode.__super__.constructor.apply(this, arguments);
      }

      AddNode.prototype.el = '#addNote';

      AddNode.prototype.events = {
        'submit': 'submit'
      };

      AddNode.prototype.submit = function(e) {
        var node, text, username;
        e.preventDefault();
        text = $(e.currentTarget).find('input[name=text]').val();
        username = $(e.currentTarget).find('input[name=username]').val();
        node = new App.Models.Node({
          text: text || "empty",
          username: username || 'anonymous'
        });
        return this.collection.add(node);
      };

      return AddNode;

    })(Backbone.View);
    collectionNodes = new App.Collections.Nodes();
    addNodeView = new App.Views.AddNode({
      collection: collectionNodes
    });
    nodeCollectionView = new App.Views.NodesCollection({
      collection: collectionNodes
    });
    return $(".nodes").append(nodeCollectionView.render().el);
  })();

}).call(this);

//# sourceMappingURL=App.map
