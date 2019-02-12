using UnityEngine;

public class RotationTransformation: Transformation {
    // 旋转角度
    public Vector3 rotation;

    public override Vector3 Apply(Vector3 point) {
        return point;
    }

}