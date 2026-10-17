package graphics.ui;

import sound.SoundManager;
import hxd.snd.Manager;
import utilities.Utilities.clamp;
import utilities.Vector2D;
import utilities.MessageManager;
import hxd.Window;
import hxd.snd.ChannelBase;
import hxd.Event;
import hxd.Res;
import h2d.col.Circle;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;

class MasterChannelWrapper extends ChannelBase {

	override function set_volume(v) {
		currentFade = null;
		return Manager.get().masterVolume = v;
	}

}

class UIVolumeSlider extends Object implements MessageListener {
    // 206 total width
    // 13 cap
    public var startPos = new Vector2D(-87, 0);
    public var endPos = new Vector2D(87, 0);
    
    var slider: Bitmap;
    var channel: ChannelBase;
    
    var isSelected = false;

    var min: Float;
    var max: Float;

    var isGlobalMute: Bool;
    
    public function new(c: ChannelBase, ?p: Object, ?_min=0.0, ?_max=1.0, ?is_global_mute=false) {
        super(p);

        isGlobalMute = is_global_mute;
        channel = c;
        min = _min;
        max = _max;
        channel.volume = 0.5*(min + max);

        slider = new Bitmap(Res.img.Slider.toTile().center(), this);
        // slider.x = startPos.x;
        
        var i = new Interactive(0, 0, slider, new Circle(0, 0, 22));
        i.onPush = (e: Event) -> {
            isSelected = true;
        };
        i.onRelease = (e: Event) -> {
            isSelected = false;
            if (isGlobalMute)
                MessageManager.send(new SetGlobalMuteButton(channel.volume != 0));
        };

        MessageManager.addListener(this);
    }

    public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var start_abs = localToGlobal(startPos);
            var end_abs = localToGlobal(endPos);
            
            var mouse_x = Window.getInstance().mouseX;
            var x_diff = mouse_x - start_abs.x;
            
            var r = 1 - x_diff/(end_abs.x - start_abs.x);
            r = clamp(r, 0, 1);
            
            channel.volume = min*r + max*(1 - r);

            slider.x = r*startPos.x + (1-r)*endPos.x;

            SoundManager.dynamicEQ();
        }
        if (Std.isOfType(msg, ToggleMuteGlobal) && isGlobalMute) {
            var r = channel.volume;
            slider.x = r*startPos.x + (1-r)*endPos.x;
        }
        return false;
    }
}