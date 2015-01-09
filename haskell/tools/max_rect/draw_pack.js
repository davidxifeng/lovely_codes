
var MyLayer = cc.Layer.extend({
    ctor : function() {
        this._super();
    },

    m_dn : null,

    init : function() {
        this._super();

        var size = cc.director.getWinSize();

        var label = cc.LabelTTF.create("layout demo", "Arial", 40);
        label.setPosition(0, size.height);
        label.setAnchorPoint(0, 1);
        this.addChild(label);

        this.m_dn = new cc.DrawNode();
        this.m_dn.setAnchorPoint(0, 0);
        this.addChild(this.m_dn);
    },

    showRects : function(result) {
        var fillColor = cc.color(255, 255, 255, 255);
        var lineWidth = 1;
        var lineColor = cc.color.GREEN;

        for (var rck in result) {
            var rcs = result[rck].rects;
            for (var k in rcs) {
                var rc = rcs[k];
                var o = { x : rc.x, y : rc.y};
                var d = { x : rc.w, y : rc.h};
                this.m_dn.drawRect(o, d, fillColor, lineWidth, lineColor);
            }
        }
    },
});



window.onload = function() {
    cc.game.onStart = function() {
        //load resources
        cc.LoaderScene.preload([], function () {
            var MyScene = cc.Scene.extend({
                onEnter:function () {
                    this._super();
                    var mylayer = new MyLayer();
                    mylayer.init();

                    var url = "x/api";
                    var cb = function(e, r) {
                        if (!e) {
                            mylayer.showRects(r);
                        }
                    };
                    cc.loader.loadJson(url, cb);

                    this.addChild(mylayer);
                }
            });
            cc.director.runScene(new MyScene());
        }, this);
    };
    cc.game.run("gameCanvas");
};
