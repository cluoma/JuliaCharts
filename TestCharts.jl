using Plots


# Spiral chart
const rotations = 3
x = []
y = []
r = 0
θ = 1
while θ <= rotations * 2π && θ >= -1 * rotations * 2π

    x = cat(1, x, r * cos(θ))
    y = cat(1, y, r * sin(θ))

    r += 2π / θ
    θ += 0.01 * rotations * abs(2π / θ)

end
plot(x,y)
