package graphics;

import hxd.res.DefaultFont;
import h2d.Text;
import h2d.Bitmap;
import hxd.Res;
import h2d.Graphics;
import h2d.Object;

class HungerBar extends Object {

    var progress: Graphics;
    var text: Text;

    public function new(p: Object) {
        super(p);

        x = 800;
        y = 850;
        
        progress = new Graphics(this);
        var border = new Graphics(progress);
        var meat_symbol = new Bitmap(Res.img.Meat.toTile().center(), border);
        meat_symbol.x = -200;
        meat_symbol.y = -20;

        border.lineStyle(10, 0x222222);
        border.addVertex(-200, -25, 1, 1, 1, 1);
        border.addVertex(200, -25, 1, 1, 1, 1);
        border.addVertex(200, 25, 1, 1, 1, 1);
        border.addVertex(-200, 25, 1, 1, 1, 1);
        border.addVertex(-200, -25, 1, 1, 1, 1);

        text = new Text(DefaultFont.get(), this);
        text.smooth = false;
        text.x = 0;
        text.y = -34;
        text.textColor = 0x222222;
        text.scale(4);
        text.textAlign = Center;
    }

    public function update(percent: Float) {
        progress.clear();
        progress.beginFill(0xAA0000);
        progress.drawRect(-200, -25, 400*percent, 50);

        if (percent == 0)
            text.text = "You Starved";
    }

}