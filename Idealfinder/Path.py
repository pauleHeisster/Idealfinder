import numpy as np
import math

class Path(object):
    type
    _x = np.array
    _y = np.array
    _z = np.array

    def __init__(self, type='linear'):
        self.type = type

    def setCoordinates(self, x, y, z):
        if len(x) == len(y) and \
            len(x) == len(z) and \
            len(y) == len(z):
            self._x = x
            self._y = y
            self._z = z

    def append(self, xyz):
        self._x = xyz[0]
        self._y = xyz[1]
        if len(xyz) > 2:
            self._z = xyz[2]
        else:
            self._z = 0

    def getPath(self):
        return [self._x, self._y, self._z]

class Generator:
    @staticmethod
    def create(a_radius, a_length, starting_at=[0,0]):
        if not len(a_radius) == len(a_length):
            print("length of inputs are not equal")
            return
        oPath = Path()
        oPath.append(starting_at)

        a_radius = [np.inf if x == 0 else x for x in a_radius]
        arcEnd = 0
        arc_center = [-np.inf,0]
        direction = np.sign(arc_center) # left/right | front/rear | up/down
        last_pos = starting_at
        lastRadius = np.inf
        for i in range(0, len(a_radius)-1):
            curRadius = a_radius[i]
            curLength = a_length[i]
            if i > 0:
                if not np.isinf(lastRadius):
                    aMPN = (arc_center[:-1]-oPath.getPath[:-1])/lastRadius
                    direction = aMPN
                arc_center += oPath.getPath[:-1]+direction*curRadius

            arcTemp = arcEnd + (90 - 90*np.sign(curRadius)*np.sign(lastRadius))
            arcStart = arcTemp % 360
            nElements = math.floor(curLength)
            if curRadius == np.inf:
                alpha = 0
                aTemp = np.zeros((nElements, 2))
                aTemp[:1] = range(0, nElements-1)
                aTemp = Rotate(aTemp, arcStart+90) + oPath.getPath[:-1]
            else:
                alpha = curLength*180/(curRadius*math.pi)
                t = np.linspace(arcStart, arcStart+alpha, nElements)
                aTemp = np.abs(curRadius)*[math.cos(t), math.sin(t)] + arc_center[:-1]

            for new_position in aTemp[1:]: # skip the first element, because it is the already added
                oPath.append(new_position)

            arcEnd = arcStart+alpha
            lastRadius = curRadius

        print("Path has been created")
        return oPath


def Rotate(vec, alpha):
    aRot = [
        cosd(alpha), sind(alpha)
        -sind(alpha), cosd(alpha)
        ]
    return vec*aRot

def main():
    print("Starting the Generator")
    Generator.create([0,30,0,45,0],[10,10,15,10,5])

if __name__ == "__main__":
    main()
