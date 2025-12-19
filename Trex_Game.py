#!/usr/bin/env python3
import curses
import time
import random
import os

# ================= CONFIG =================
FPS = 60
DT = 1 / FPS
GRAVITY = 70.0
JUMP_VELOCITY = -45.0
SCROLL_SPEED = 22.0
SPEED_INCREASE = 0.015
HIGH_SCORE_FILE = "highscore.txt"
# =========================================

DINO = [
"               __ ",
"              / _)",
"     _.^^^^._/ /  ",
"    /         /   ",
" __/ (  | (  |    ",
"/__.-'|_|--|_|    "
]

CACTUS = [
"    ,*-.     ",
"    |  |     ",
",.  |  |     ",
"| |_|  | ,.  ",
"`---.  |_| | ",
"    |  .--`  ",
"    |  |     "
]

CLOUD = [
"    ████   ",
"   ███████ ",
" ██████████"
]

GROUND_PATTERN = "··"

# ===== High Score =====
def load_highscore():
    if not os.path.exists(HIGH_SCORE_FILE):
        with open(HIGH_SCORE_FILE, "w") as f:
            f.write("0")
        return 0
    with open(HIGH_SCORE_FILE, "r") as f:
        try:
            return int(f.read())
        except:
            return 0

def save_highscore(score):
    high = load_highscore()
    if score > high:
        with open(HIGH_SCORE_FILE, "w") as f:
            f.write(str(int(score)))

# ===== MAIN MENU =====
def main_menu(stdscr, highscore):
    curses.curs_set(0)
    h, w = stdscr.getmaxyx()
    option = 0
    options = ["Start Game", "Quit"]

    while True:
        stdscr.erase()
        title = "T-REX CLI GAME"
        stdscr.addstr(h//2 - 6, (w - len(title))//2, title, curses.A_BOLD)

        author = "Made by: James Rivers"
        stdscr.addstr(h//2 - 4, (w - len(author))//2, author)

        hs_text = f"HIGH SCORE: {highscore}"
        stdscr.addstr(h//2 - 2, (w - len(hs_text))//2, hs_text)

        for idx, text in enumerate(options):
            x = (w - len(text)) // 2
            y = h//2 + idx * 2
            if idx == option:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(y, x, text)
                stdscr.attroff(curses.A_REVERSE)
            else:
                stdscr.addstr(y, x, text)
        stdscr.refresh()

        key = stdscr.getch()
        if key in (curses.KEY_UP, ord('w'), ord('W')):
            option = (option - 1) % len(options)
        elif key in (curses.KEY_DOWN, ord('s'), ord('S')):
            option = (option + 1) % len(options)
        elif key in (ord('\n'), ord(' ')):
            if option == 0:
                return  # Start Game
            else:
                exit()  # Quit

# ===== GAME LOGIC =====
def play_game(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.keypad(True)
    h, w = stdscr.getmaxyx()
    ground_y = h - 5

    # Dino state
    dino_x = 6
    dino_y = ground_y - len(DINO)
    dino_vy = 0.0
    on_ground = True

    obstacles = []
    clouds = []
    score = 0
    speed = SCROLL_SPEED
    last_time = time.time()

    # Spawn timers
    next_obstacle = random.uniform(1.0, 1.8)
    next_cloud = random.uniform(2.0, 4.0)

    ground_offset = 0  # For smooth ground scrolling

    while True:
        now = time.time()
        dt = now - last_time
        last_time = now

        # ===== INPUT =====
        key = stdscr.getch()
        if key in (ord('q'), ord('Q')):
            return score
        if key in (ord(' '), curses.KEY_UP):
            if on_ground:
                dino_vy = JUMP_VELOCITY
                on_ground = False

        # ===== PHYSICS =====
        if not on_ground:
            dino_vy += GRAVITY * dt
            dino_y += dino_vy * dt
            if dino_y >= ground_y - len(DINO):
                dino_y = ground_y - len(DINO)
                dino_vy = 0
                on_ground = True

        # ===== SPAWN =====
        next_obstacle -= dt
        if next_obstacle <= 0:
            obstacles.append({
                "x": w - 2,
                "y": ground_y - len(CACTUS)
            })
            next_obstacle = random.uniform(1.25, 2.5)

        next_cloud -= dt
        if next_cloud <= 0:
            clouds.append({
                "x": w - 2,
                "y": random.randint(1, ground_y - 10)
            })
            next_cloud = random.uniform(2.5, 5.0)

        # ===== MOVE WORLD =====
        speed += SPEED_INCREASE
        for o in obstacles:
            o["x"] -= speed * dt
        for c in clouds:
            c["x"] -= (speed * 0.3) * dt

        obstacles = [o for o in obstacles if o["x"] > -6]
        clouds = [c for c in clouds if c["x"] > -len(CLOUD[0])]

        ground_offset = (ground_offset + speed * dt) % len(GROUND_PATTERN)

        # ===== COLLISION =====
        for o in obstacles:
            if dino_x + 2 >= int(o["x"]) >= dino_x:
                if dino_y + len(DINO) >= o["y"]:
                    return score  # Game Over

        # ===== DRAW =====
        stdscr.erase()

        # Clouds
        for c in clouds:
            for i, row in enumerate(CLOUD):
                y = c["y"] + i
                x = int(c["x"])
                if 0 <= y < h and 0 <= x < w - len(row):
                    stdscr.addstr(y, x, row)

        # Dino
        for i, row in enumerate(DINO):
            stdscr.addstr(int(dino_y) + i, dino_x, row)

        # Cactus
        for o in obstacles:
            for i, row in enumerate(CACTUS):
                x = int(o["x"])
                y = o["y"] + i
                if 0 <= y < h and 0 <= x < w - len(row):
                    stdscr.addstr(y, x, row)

        # Ground
        for x in range(-int(ground_offset), w, len(GROUND_PATTERN)):
            if 0 <= x < w - len(GROUND_PATTERN):
                stdscr.addstr(ground_y, x, GROUND_PATTERN)

        # Score
        score += dt * 10
        stdscr.addstr(1, w - 18, f"{int(score):06}")

        stdscr.refresh()
        time.sleep(DT)

# ===== GAME OVER SCREEN =====
def game_over(stdscr, score):
    save_highscore(score)
    highscore = load_highscore()
    h, w = stdscr.getmaxyx()
    msg = " GAME OVER "
    scr = f"SCORE: {int(score)}"
    hs_text = f"HIGH SCORE: {highscore}"
    stdscr.nodelay(False)
    stdscr.erase()
    stdscr.addstr(h // 2 - 1, (w - len(msg)) // 2, msg)
    stdscr.addstr(h // 2, (w - len(scr)) // 2, scr)
    stdscr.addstr(h // 2 + 1, (w - len(hs_text)) // 2, hs_text)
    stdscr.addstr(h // 2 + 3, (w - 30) // 2, "Press any key to return to menu")
    stdscr.refresh()
    stdscr.getch()

# ===== ENTRY POINT =====
def main(stdscr):
    while True:
        highscore = load_highscore()
        main_menu(stdscr, highscore)
        score = play_game(stdscr)
        game_over(stdscr, score)

if __name__ == "__main__":
    curses.wrapper(main)

