using UnityEngine;

public class ScaleTransformation: Transformation {
    // 缩放比率
    public Vector3 scale;

    public override Vector3 Apply(Vector3 point) {
        point.x *= scale.x;
        point.y *= scale.y;
        point.z *= scale.z;
        return point;
    }

}