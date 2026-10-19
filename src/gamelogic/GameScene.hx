package gamelogic;

import graphics.Cow;
import graphics.Arrow;
import graphics.Hut;
import graphics.Farmer;
import graphics.SpearProjectile;
import graphics.Doodad;
import utilities.Vector2D;
import graphics.Tracks;
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
        MessageManager.send(new SplashScreenStart());

        // for respawns
        if (Sky.night >= 2)
            spawnFarm();
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

    function spawnCows() {
        var r = RNGManager.randomAngle();
        var p = new Vector2D(1000, 0).rotate(r);
        var tracks = new Tracks(background, false);
        tracks.x = 800 + p.x;
        tracks.y = 450 + p.y;
        tracks.rotation = r;

        var d = 1500 + RNGManager.random(1000);
        p = new Vector2D(d, 0).rotate(r);
        for (_ in 0...1+RNGManager.random(3)) {
            var cow = new Cow(background);
            cow.x = 800 + p.x + RNGManager.srand(500);
            cow.y = 450 + p.y + RNGManager.srand(500);
            updateables.push(cow);
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

    function spawnFarm() {
        trace("spawn farm");
        var r = RNGManager.randomAngle();
        var center = new Vector2D(2600 + RNGManager.random(1000), 0).rotate(r);

        var prev = center;
        for (x in 0...150) {
            var theta = 2*Math.PI*x/20;
            var radius = 20*theta;
            var x = center.x + radius*Math.cos(theta);
            var y = center.y + radius*Math.sin(theta);
            var p = new Vector2D(x, y);
            if ((p - prev).magnitude > 100) {
                var doodad = new Doodad(background, true);
                doodad.x = x;
                doodad.y = y;
                prev = p;
            }
        }
        var h = new Hut(background);
        h.x = center.x;
        h.y = center.y;
        var f = new Farmer(background);
        f.x = center.x;
        f.y = center.y;
    }

    public function update(dt:Float) {
        if (isPaused) return;

        timeTillSpawn -= dt;
        if (timeTillSpawn <= 0) {
            timeTillSpawn = timeTillSpawnMax;
            spawnDoodads();
            if (Sky.night == 0)
                spawnPorcs();
            else {
                if (RNGManager.random(2) == 0)
                    spawnPorcs();
                else
                    spawnCows();
            }
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
        if (Std.isOfType(msg, ThrowSpear)) {
            var pos = cast(msg, ThrowSpear).pos;
            updateables.push(new SpearProjectile(pos, background));
        }
        if (Std.isOfType(msg, ShootBow)) {
            var pos = cast(msg, ShootBow).pos;
            updateables.push(new Arrow(pos, background));
        }
        if (Std.isOfType(msg, KeyUp) && splash) {
            splash = false;
            isPaused = false;
            splashScreen.visible = false;
            MessageManager.send(new SplashScreenEnd());
        }
        if (Std.isOfType(msg, NightPasses)) {
            var n = cast(msg, NightPasses).number;
            trace(n);
            if (n == 1)
                spawnCows();
            if (n >= 2)
                spawnFarm();
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
