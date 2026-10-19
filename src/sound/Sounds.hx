package sound;

import hxd.snd.Manager;
import hxd.res.Sound;
import hxd.res.Loader;
import hxd.Res;
import utilities.MessageManager;

class Sounds implements MessageListener {

    static var init = false;
    static var sounds: Sounds;
    var loader: Loader;
    var manager: Manager;

    var music: Sound;
    
    public function new() {
        loader = Loader.currentInstance;
        manager = Manager.get();
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
            manager.stopAll();
            music = Res.snd.Chant;
            var c = music.play(true);
            c.volume = 0.25;
            var music2 = Res.snd.Cave;
            music2.play(true);
        }
        if (Std.isOfType(msg, SplashScreenEnd) || Std.isOfType(msg, NightEnds)) {
            manager.stopAll();
            music = Res.snd.Ambience;
            music.play(true);
        }
        if (Std.isOfType(msg, NightBegins)) {
            manager.stopAll();
            music = Res.snd.Night;
            music.play(true);
        }
        return false;
    }
}