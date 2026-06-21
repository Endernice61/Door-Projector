function isVector(vec) {
	return vec.tostring == Vector(1,0,0).tostring;
}

function isMatrix(mat) {
	return mat instanceof Matrix;
}

getroottable().isVector <- isVector;
getroottable().isMatrix <- isMatrix;

getroottable().Matrix <- class {
	static IDENTITY = [[1,0,0],[0,1,0],[0,0,1]];
	matrix = null;
	constructor(...) {
		//try {
			construct1(vargv[0]);
		//} catch (error) {
		//	matrix = IDENTITY;
		//}
		//throw("Wrong number of parameters");
	}
	function construct1(m) {
		matrix = m;
		/*if (m.len() != 3) {
			Assert(null,"3x3 matrices only");
		}*/
		foreach (i, v in m) {
			if (isVector(v)) {
				m[i]=[v.x,v.y,v.z];
			}
		}
	}
	function fromEntity(e) {
		return Matrix([e.GetForwardVector(),e.GetUpVector(),e.GetLeftVector()]);
	}
	function transpose() {
		local m = [clone(matrix[0]),clone(matrix[1]),clone(matrix[2])];
		for (local i = 0; i<3; ++i) for (local j = 0; j<3; ++j) {
			matrix[i][j] = m[j][i];
		}
	}
	function Clone() {
		return Matrix([clone(matrix[0]),clone(matrix[1]),clone(matrix[2])]);
	}
	function vector(arr) {
		if (arr.len() != 3) { throw("Cannot convert array to vector"); }
		return Vector(arr[0],arr[1],arr[2]);
	}
	function getVectorMatrix() {
		return [vector(matrix[0]),vector(matrix[1]),vector(matrix[2])];
	}
	function _mul(other) {
		//printl("Multiplying..");
		if (other instanceof Vector) {
			//printl("Multiplying against Vector...");
			local m = getVectorMatrix();
			return Vector(other.Dot(m[0]),other.Dot(m[1]),other.Dot(m[2]));
		}
		//printl("Not a vector...");
		if (isMatrix(other)) {
			//printl("Multiplying against Matrix...");
			local m = other.Clone();
			m.transpose();
			m = Matrix([this*vector(m.matrix[0]),this*vector(m.matrix[1]),this*vector(m.matrix[2])]);
			m.transpose();
			return m;
		}
		Assert(null,"Unknown multiplication operation");
	}
	function tostring() {
		local s = "";
		foreach (arr in matrix) {
			s += "[ ";
			foreach (i in arr) {
				s += i;
				s += " ";
			}
			s += "]\n";
		}
		return s;
	}
}