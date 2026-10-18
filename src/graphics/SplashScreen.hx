package graphics;

import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class SplashScreen extends Object {

    public function new(p: Object) {
        super(p);
        new Bitmap(Res.img.TitleScreen.toTile(), this);
    }

}