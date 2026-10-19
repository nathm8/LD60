package sound;

import hxd.res.Sound;
import hxd.res.Loader;
import hxd.Res;
import utilities.MessageManager;

class Sounds implements MessageListener {

    static var init = false;
    static var sounds: Sounds;
    var loader: Loader;

    var music: Sound;
    
    public function new() {
        loader = Loader.currentInstance;
        MessageManager.addListener(this);
    }

    public static function initialise(s=-1) {
        if (init) return;
        init = true;
        sounds = new Sounds();
    }
    
    public static function reset() {
        init = false;
        initialise();
    }

    public function receive(msg: Message):Bool {
        if (Std.isOfType(msg, SplashScreenStart)) {
            music = Res.snd.Chant;
            music.play();
        }
        if (Std.isOfType(msg, SplashScreenEnd)) {
            music.stop();
            
        }
        return false;
    }
}