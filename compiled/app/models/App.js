// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function() {
    var nodeCollection, nodeCollectionView;
    window.App = {
      Models: {},
      Collections: {},
      Views: {}
    };
    window.template = function(id) {
      return _.template($("#" + id).html());
    };
    App.Models.Node = (function(_super) {
      __extends(Node, _super);

      function Node() {
        return Node.__super__.constructor.apply(this, arguments);
      }

      return Node;

    })(Backbone.Model);
    App.Views.Node = (function(_super) {
      __extends(Node, _super);

      function Node() {
        return Node.__super__.constructor.apply(this, arguments);
      }

      Node.prototype.tagName = 'li';

      Node.prototype.render = function() {
        this.$el.html(this.model.get('name'));
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

      return Nodes;

    })(Backbone.Collection);
    App.Views.NodesCollection = (function(_super) {
      __extends(NodesCollection, _super);

      function NodesCollection() {
        return NodesCollection.__super__.constructor.apply(this, arguments);
      }

      NodesCollection.prototype.tagName = 'div';

      NodesCollection.prototype.render = function() {
        this.collection.each(this.addOne, this);
        return this;
      };

      NodesCollection.prototype.addOne = function(node) {
        var nodeView;
        nodeView = new App.Views.Node({
          model: node
        });
        return this.$el.append(nodeView.render().el);
      };

      return NodesCollection;

    })(Backbone.View);
    nodeCollection = new App.Collections.Nodes([
      {
        name: "Mike T",
        text: "Hello World"
      }, {
        name: "Peter T",
        text: "What's up?"
      }, {
        name: "Jossy",
        text: "Hey bros"
      }
    ]);
    nodeCollectionView = new App.Views.NodesCollection({
      collection: nodeCollection
    });
    return $(".nodes").append(nodeCollectionView.render().el);
  })();

}).call(this);

//# sourceMappingURL=App.map
