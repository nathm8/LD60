package sound;

import utilities.RNGManager;
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
            var music = Res.snd.Chant;
            var c = music.play(true);
            c.volume = 0.25;
            Res.snd.Cave.play(true);
        }
        if (Std.isOfType(msg, SplashScreenEnd) || Std.isOfType(msg, NightEnds)) {
            manager.stopAll();
            Res.snd.Ambience.play(true);
        }
        if (Std.isOfType(msg, NightBegins)) {
            manager.stopAll();
            Res.snd.Night.play(true);
        }
        if (Std.isOfType(msg, AnimalEaten)) {
            if (RNGManager.random(2) == 0)
                Res.snd.Eat1.play();
            else
                Res.snd.Eat2.play();
        }
        if (Std.isOfType(msg, ShootBow)) {
            if (RNGManager.random(2) == 0)
                Res.snd.Bow1.play();
            else
                Res.snd.Bow2.play();
        }
        if (Std.isOfType(msg, SpawnBloodSpray)) {
            RNGManager.pick_random([Res.snd.Hit1, Res.snd.Hit2, Res.snd.Hit3, Res.snd.Hit4]).play();
        }
        if (Std.isOfType(msg, CowChase))
            RNGManager.pick_random([Res.snd.CowSnort1, Res.snd.CowSnort2]).play();
        if (Std.isOfType(msg, CowHurt))
            RNGManager.pick_random([Res.snd.CowDeath1, Res.snd.CowDeath2, Res.snd.CowDeath3]).play();
        if (Std.isOfType(msg, PorcHurt))
            RNGManager.pick_random([Res.snd.PorcDeath, Res.snd.PorcFlee1, Res.snd.PorcFlee2]).play();
        if (Std.isOfType(msg, PlayerHurt) || Std.isOfType(msg, FarmerHurt))
            RNGManager.pick_random([Res.snd.HumanHurt1, Res.snd.HumanHurt2, Res.snd.HumanHurt3]).play();
        return false;
    }
}