
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

    showRects : function(rcs) {
        var fillColor = cc.color(255, 255, 255, 255);
        var lineWidth = 5;
        var lineColor = cc.color.GREEN;
        for (var k in rcs) {
            var rc = rcs[k];
            this.m_dn.drawRect(rc.o, rc.d, fillColor, lineWidth, lineColor);
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

                    var rs = [
                        {o : {x : 5, y : 5}, d : {x : 128, y : 64}},
                        {o : {x : 200, y : 400}, d : {x : 64, y : 128}},
                    ];
                    mylayer.showRects(rs);

                    this.addChild(mylayer);
                }
            });
            cc.director.runScene(new MyScene());
        }, this);
    };
    cc.game.run("gameCanvas");
};
