package utilities;

import graphics.PlayerCharacter;
import hxd.fs.FileEntry;
import hxd.Event;
import utilities.Vector2D;

class Message {public function new(){}}

class Victory extends Message {}
class Restart extends Message {}
class AnimalEaten extends Message {}
class MousePush extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class KeyDown extends Message {
    public var keycode: Int;
    public function new(k: Int) {super(); keycode = k;}
}
class KeyUp extends Message {
    public var keycode: Int;
    public function new(k: Int) {super(); keycode = k;}
}
class MouseRelease extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class MouseMove extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class MouseWheel extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class MoveWorld extends Message {
    public var move: Vector2D;
    public function new(p: Vector2D) {super(); move = p;}
}
class SpawnBloodSpray extends Message {
    public var pos: Vector2D;
    public var damage: Float;
    public function new(p: Vector2D, d: Float) {super(); pos = p; damage = d;}
}
class ThrowSpear extends Message {
    public var pos: Vector2D;
    public function new(p: Vector2D) {super(); pos = p;}
}
class WeaponDamageCheck extends Message {
    public var pos: Vector2D;
    public var damage: Float;
    public function new(p: Vector2D, d: Float) {super(); damage = d; pos = p;}
}
class PlayerCollisionCheck extends Message {
    public var player: PlayerCharacter;
    public function new(p: PlayerCharacter) {super(); player = p;}
}
class StartLevel extends Message {
    public var levelId: Int;
    public var delete: Bool;
    public function new(i: Int, d=false) {super(); levelId = i; delete=d;}
}
class EnableProgression extends Message {}
class DisableProgression extends Message {}
class ToggleMuteGlobal extends Message {}
class MainMenu extends Message {}
class TogglePause extends Message {}

interface MessageListener {
    public function receive(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

    public static function addListener(l:MessageListener) {
        listeners.push(l);
    }

    public static function removeListener(l:MessageListener) {
        listeners.remove(l);
    }

    public static function send(msg: Message) {
        for (l in listeners)
            if (l.receive(msg)) return;
        // trace("unconsumed message", msg);
    }

    public static function reset() {
        listeners = [];
    }

}