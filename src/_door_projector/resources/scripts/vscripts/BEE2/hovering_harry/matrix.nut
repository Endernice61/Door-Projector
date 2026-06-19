class Matrix {
	static IDENTITY = [[1,0,0],[0,1,0],[0,0,1]];
	matrix = null;
	constructor(...) {
		try {
			matrix = vargv[0];
		} catch (error) {
			matrix = IDENTITY;
		}
		//throw("Wrong number of parameters");
	}
	function vector(arr) {
		if (arr.len() != 3) { throw("Cannot convert array to vector"); }
		return Vector(arr[0],arr[1],arr[2]);
	}
	function getVectorMatrix() {
		return [vector(matrix[0]),vector(matrix[1]),vector(matrix[2])];
	}
	function _mul(other) {
		if (other instanceof Vector) {
			local m = getVectorMatrix();
			return Vector(other.Dot(m[0]),other.Dot(m[1]),other.Dot(m[2]));
		}
		throw("Unknown multiplication operation");
	}
}