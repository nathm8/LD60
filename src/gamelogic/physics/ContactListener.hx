package gamelogic.physics;

import hxd.Key;
import utilities.MessageManager;
import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;

class ContactListener extends B2ContactListener {

    override public function beginContact(contact:B2Contact) {
        super.beginContact(contact);
        var object_a = contact.getFixtureA().getUserData();
        var object_b = contact.getFixtureB().getUserData();
    }

}