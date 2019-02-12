using UnityEngine;
using System.Collections.Generic;

public class TransformationGrid : MonoBehaviour {
    public Transform prefab;
    // 矩阵解析度-->分辨率
    public int gridResolution = 10;
    Transform[] grid;
    List<Transformation> transformations;
    
    void Awake() {
        grid = new Transform[gridResolution * gridResolution * gridResolution];
        for (int i = 0, z = 0; z < gridResolution; z++) {
            for (int y = 0; y < gridResolution; y++) {
                for (int x = 0; x < gridResolution; x++, i++) {
                    grid[i] = CreateGridPoint(x, y, z);
                }
            }
        }
        transformations = new List<Transformation>();
    }
    void Update() {
        GetComponents<Transformation>(transformations);
        for (int i = 0, z = 0; z < gridResolution; z++) {
            for (int y = 0; y < gridResolution; y++) {
                for (int x = 0; x < gridResolution; x++, i++) {
                    grid[i].localPosition = TransformPoint(x, y, z);
                }
            }
        }
    }

    // 创建网格点
    Transform CreateGridPoint(int x, int y, int z) {
        Transform point = Instantiate<Transform>(prefab);
        point.localPosition = GetCoordinates(x, y, z);
        point.GetComponent<MeshRenderer>().material.color = new Color(
            (float)x / gridResolution,
            (float)y / gridResolution,
            (float)z / gridResolution
        );
        return point;
    }

    // 获取(原有)坐标 Coordinates: 坐标
    Vector3 GetCoordinates(int x, int y, int z) {
        return new Vector3(
            x - (gridResolution - 1) * 0.5f,
            y - (gridResolution - 1) * 0.5f,
            z - (gridResolution - 1) * 0.5f
        );
    }
    
    // 变换坐标
    Vector3 TransformPoint (int x, int y, int z) {
        // 获取原有坐标后 然后应用到要转换的身上
		Vector3 coordinates = GetCoordinates(x, y, z);
		for (int i = 0; i < transformations.Count; i++) {
			coordinates = transformations[i].Apply(coordinates);
		}
		return coordinates;
	}

}
