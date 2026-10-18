package utilities;

typedef Bone = {
    var length: Float;
    var angle: Float;
}

final MAX_ITERATIONS = 100;
final EPSILON = 1e-6;

function polar_to_cartesian(length: Float, angle: Float) : Vector2D {
    return length * new Vector2D(Math.cos(angle), Math.sin(angle));
}

// FABRIK
// https://github.com/chFleschutz/inverse-kinematics-algorithms

class InverseKinematics {

    public static function solve(bones: Array<Bone>, target: Vector2D): Void {
        // initialise joints
        var joints = [new Vector2D()];
        var angle = 0.0;
        var prev = joints[0];
        for (b in bones) {
            angle += b.angle;
            var j = prev + polar_to_cartesian(b.length, b.angle);
            joints.push(j);
            prev = j;
        }

        // set target to be our max length in the target direction
        // if it is beyond it
        var max_length = 0.0;
        for (b in bones)
            max_length += b.length;
        if (target.magnitude > max_length)
            target = target.normalize() * max_length;
        
        // do IK
        var joint_tip_index = joints.length - 1;
        for (iterations in 0...MAX_ITERATIONS) {
            // break check
            if ((joints[joint_tip_index] - target).magnitude < EPSILON) {
                break;
            }
            // forward
            joints[joint_tip_index] = target;
            var i = joint_tip_index - 1;
            while (i > 0) {
                joints[i] = joints[i + 1] + bones[i].length*(joints[i] - joints[i + 1]).normalize();
                i--;
            }
            // back
            joints[0] = new Vector2D(0,0);
            for (i in 1...joint_tip_index)
                joints[i] = joints[i - 1] + bones[i - 1].length * (joints[i] - joints[i - 1]).normalize();
        }

        // update bones
        var last_vec = new Vector2D(1, 0);
        for (i in 0...bones.length) {
            var v = (joints[i + 1] - joints[i]).normalize();
            bones[i].angle = Math.atan2(v.y, v.x) - Math.atan2(last_vec.y, last_vec.x);
            last_vec = v;
        }
    }
}