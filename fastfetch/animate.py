#!/usr/bin/env python3
import os, time, math, sys, random

chars = 'ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ:;+=-'

def animate():
    os.system('tput civis')
    size = os.get_terminal_size()
    cols, rows = size.columns, size.lines - 1
    cx, cy = cols / 2, rows / 2
    frames = 35
    fov = 1.5
    speed = 0.15

    for frame in range(frames):
        z_offset = frame * speed
        output = []
        for r in range(rows):
            line = ''
            for c in range(cols):
                dx = (c - cx) / cx
                dy = (r - cy) / cy * 2  # correct for terminal char aspect ratio

                dist = math.sqrt(dx*dx + dy*dy)
                if dist < 0.001:
                    line += '\033[1;35m@\033[0m'
                    continue

                # perspective: project ray into tunnel
                # z increases toward center (vanishing point)
                z = fov / (dist + 0.001) + z_offset

                # grid lines in 3D space
                grid_x = abs((dx / dist * z) % 1 - 0.5)
                grid_y = abs((dy / dist * z) % 1 - 0.5)
                thickness = 0.06 + dist * 0.04
                on_grid = grid_x < thickness or grid_y < thickness

                # brightness based on depth
                brightness = min(1.0, 1.0 / (dist * 2 + 0.3))

                if on_grid:
                    if brightness > 0.7:
                        ch = random.choice(chars) if random.random() < 0.3 else '+'
                        line += f'\033[1;35m{ch}\033[0m'
                    elif brightness > 0.4:
                        line += f'\033[0;35m+\033[0m'
                    elif brightness > 0.2:
                        line += f'\033[2;35m.\033[0m'
                    else:
                        line += f'\033[2;35m \033[0m'
                else:
                    if random.random() < 0.008 * brightness:
                        line += f'\033[2;35m{random.choice(chars)}\033[0m'
                    else:
                        line += ' '
            output.append(line)

        sys.stdout.write('\033[H' + '\n'.join(output))
        sys.stdout.flush()
        time.sleep(0.04)

    os.system('tput cnorm')
    os.system('clear')

animate()
