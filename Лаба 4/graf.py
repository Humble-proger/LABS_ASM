import matplotlib.pyplot as plt
import numpy as np
from math import tan

x = np.linspace(-2, 2, 5000)
y = np.tan(x)

plt.plot(x, y, label="f(x)=tan(x) + x")
plt.legend()
plt.show()