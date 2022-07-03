var startIdx = 0;
function getNextColor() {
    var colors = [
        cc.color(255, 0, 0),
        cc.color(0, 255, 0),
        cc.color(0, 0, 255),
    ];
    if (startIdx == colors.length) {
        startIdx = 0;
    }
    return colors[startIdx++];
}

var MyLayer = cc.Layer.extend({
    ctor : function() {
        this._super();
    },

    m_sv : null,

    init : function() {
        this._super();

        var size = cc.director.getWinSize();

        var label = cc.LabelTTF.create("layout demo", "Arial", 40);
        label.setPosition(0, size.height);
        label.setAnchorPoint(0, 1);
        this.addChild(label);

        var scrollView = new ccui.ScrollView();
        scrollView.setDirection(ccui.ScrollView.DIR_HORIZONTAL);
        scrollView.setTouchEnabled(true);
        scrollView.setContentSize(cc.size(840, 670));
        scrollView.setPosition(0, 0);
        scrollView.setAnchorPoint(0, 0);

        this.addChild(scrollView);
        this.m_sv = scrollView;

        this.m_sv.setInnerContainerSize(cc.size(1680, 670));
    },

    showRects2 : function(result) {
        var dn = new cc.DrawNode();
        dn.setAnchorPoint(0, 0);
        dn.setPosition(0, 0);
        this.m_sv.setInnerContainerSize(cc.size(6 * 840, 670));
        this.m_sv.addChild(dn);
        for (var i = 0; i < result.length; i++) {
            for (var j = 0; j < result[i].length; j++) {
                var rc = result[i][j];
                var o = { x : rc.x, y : rc.y};
                var d = { x : rc.x + rc.width, y : rc.y + rc.height};
                console.log(o, d);
                dn.drawRect(o, d, getNextColor());
            }
        }
    },

    showRects : function(result) {
        for (var i = 0; i < result.length; i++) {

            var dn = new cc.DrawNode();
            dn.setAnchorPoint(0, 0);
            dn.setPosition(i * 840, 0);

            for (var j = 0; j < result[i].rects.length; j++) {
                var rc = result[i].rects[j];
                var o = { x : rc.x, y : rc.y};
                var d = { x : rc.x + rc.w, y : rc.y + rc.h};
                dn.drawRect(o, d, getNextColor());
            }

            this.m_sv.setInnerContainerSize(cc.size((i + 1) * 840, 670));
            this.m_sv.addChild(dn);
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

                    var url = "file/data.json";
                    var cb = function(e, r) {
                        if (!e) {
                            mylayer.showRects2(r);
                        } else {
                            cc.log('load json data error' + e);
                        }
                    };

                    var url2 = "x/api";
                    var cb2 = function(e, r) {
                        if (!e) {
                            mylayer.showRects(r);
                        } else {
                            cc.log('load json error' + e);
                        }
                    };

                    cc.loader.loadJson(url, cb);
                    //cc.loader.loadJson(url2, cb2);

                    this.addChild(mylayer);
                }
            });
            cc.director.runScene(new MyScene());
        }, this);
    };
    cc.game.run("gameCanvas");
};
