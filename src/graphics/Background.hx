package graphics;

import utilities.RNGManager;
import hxd.Rand;
import hxsl.Types.Vec4;
import hxd.Res;
import h2d.Object;
import gamelogic.Updateable;
import h2d.Bitmap;

final BACKGROUND_COLOURS = [0xfff9f7c7, 0xfffebd7d, 0xffc09a48];

class Background extends Object implements Updateable {

    public function new(p: Object) {
        super(p);
        var tile = Res.img.Background.toTile();
        tile.setSize(1600, 800);
        var bitmap = new Bitmap(tile, this);
        bitmap.tileWrap = true;
        bitmap.y = 200;
        bitmap.color = Vec4.fromColor(RNGManager.pick_random(BACKGROUND_COLOURS));
    }

    public function update(dt:Float):Bool {
        return true;
    }

    public function delete() {}
}