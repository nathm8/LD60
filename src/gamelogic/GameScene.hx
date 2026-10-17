package gamelogic;

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

    public var isPaused(default, set) = false;

    public function new() {
        super();

        defaultSmooth = true;

        MessageManager.addListener(this);

        background = new Background(this);

        updateables.push(background);
        updateables.push(new PlayerCharacter(background));

        for (_ in 0...3) {
            var p = new Porcupine(background);
            p.x = 900 + RNGManager.srand(600);
            p.y = 400 + RNGManager.srand(200);
            updateables.push(p);
        }

        updateables.push(new Sky(this));
    }

    public function update(dt:Float) {
        if (isPaused) return;

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
            var pos = cast(msg, SpawnBloodSpray).pos;
            updateables.push(new BloodSpray(background, pos));
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
