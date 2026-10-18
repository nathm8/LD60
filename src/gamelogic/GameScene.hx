package gamelogic;

import graphics.Doodad;
import h2d.Bitmap;
import utilities.Vector2D;
import graphics.Tracks;
import hxd.Res;
import graphics.SplashScreen;
import graphics.BloodSpray;
import graphics.Sky;
import utilities.RNGManager;
import graphics.Porcupine;
import graphics.PlayerCharacter;
import graphics.Background;
import h2d.filter.Blur;
import h2d.Scene;
import gamelogic.Updateable;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {

    var updateables = new Array<Updateable>();
    var background: Background;

    public var isPaused(default, set) = true;
    var splash = true;
    var splashScreen: SplashScreen;

    var timeTillSpawn = 0.0;
    var timeTillSpawnMax = 10.0;

    public function new() {
        super();

        defaultSmooth = true;

        MessageManager.addListener(this);

        background = new Background(this);

        updateables.push(background);
        updateables.push(new PlayerCharacter(this));

        for (_ in 0...3) {
            var p = new Porcupine(background);
            p.x = 900 + RNGManager.srand(600);
            p.y = 400 + RNGManager.srand(200);
            updateables.push(p);
        }

        updateables.push(new Sky(this));

        splashScreen = new SplashScreen(this);
    }

    function spawnPorcs() {
        var r = RNGManager.randomAngle();
        var p = new Vector2D(1000, 0).rotate(r);
        var tracks = new Tracks(background);
        tracks.x = 800 + p.x;
        tracks.y = 450 + p.y;
        tracks.rotation = r;

        var d = 1500 + RNGManager.random(1000);
        p = new Vector2D(d, 0).rotate(r);
        for (_ in 0...1+RNGManager.random(5)) {
            var porc = new Porcupine(background);
            porc.x = 800 + p.x + RNGManager.srand(500);
            porc.y = 450 + p.y + RNGManager.srand(500);
            updateables.push(porc);
        }
    }

    function spawnDoodads() {
        for (_ in 0...10+RNGManager.random(10)) {
            var r = RNGManager.randomAngle();
            var p = new Vector2D(1500 + RNGManager.random(1000), 0).rotate(r);
            var doodad = new Doodad(background);
            doodad.x = 800 + p.x;
            doodad.y = 450 + p.y;
        }
    }

    public function update(dt:Float) {
        if (isPaused) return;

        timeTillSpawn -= dt;
        if (timeTillSpawn <= 0) {
            timeTillSpawn = timeTillSpawnMax;
            spawnPorcs();
            spawnDoodads();
        }

        var to_remove = new Array<Updateable>();
        for (u in updateables) {
            if (u.update(dt))
                to_remove.push(u);
        }
        for (u in to_remove)
            updateables.remove(u);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, TogglePause)) {
            isPaused = !isPaused;
        }
        if (Std.isOfType(msg, SpawnBloodSpray)) {
            var params = cast(msg, SpawnBloodSpray);
            updateables.push(new BloodSpray(background, params.pos, params.damage));
        }
        if (Std.isOfType(msg, KeyUp) && splash) {
            splash = false;
            isPaused = false;
            splashScreen.visible = false;
        }
        return false;
    }

    function set_isPaused(value) {
        if (value) {
            filter = new Blur(100, 0.9);
        }
        else
            filter = null;
        isPaused = value;
        return isPaused;
    }
}
