using UnityEngine;

public class PositionTransformation: Transformation {
    // 偏移点
    public Vector3 position;

    public override Vector3 Apply(Vector3 point) {
        return point + position;
    }

}