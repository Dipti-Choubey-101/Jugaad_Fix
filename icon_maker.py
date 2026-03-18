from PIL import Image, ImageDraw

size = 1024
img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

orange = (255, 107, 0, 255)
white = (255, 255, 255, 255)
lo = (255, 184, 122, 255)

draw.rounded_rectangle([0, 0, 1024, 1024], radius=180, fill=orange)
draw.ellipse([262, 60, 762, 510], fill=white)
draw.rounded_rectangle([392, 500, 632, 536], radius=6, fill=white)
draw.rounded_rectangle([402, 534, 622, 562], radius=6, fill=lo)
draw.rounded_rectangle([414, 560, 610, 584], radius=6, fill=lo)
draw.rounded_rectangle([428, 582, 596, 602], radius=6, fill=lo)
draw.line([(380, 430), (440, 290), (512, 380), (584, 290), (644, 430)], fill=orange, width=22)

shine = Image.new("RGBA", (size, size), (0, 0, 0, 0))
sd = ImageDraw.Draw(shine)
sd.ellipse([310, 110, 430, 320], fill=(255, 255, 255, 55))
img = Image.alpha_composite(img, shine)
draw = ImageDraw.Draw(img)

draw.rounded_rectangle([472, 630, 552, 900], radius=30, fill=white)
draw.rounded_rectangle([310, 580, 714, 670], radius=20, fill=white)
draw.ellipse([282, 592, 372, 658], fill=orange)
draw.ellipse([652, 592, 742, 658], fill=orange)
draw.ellipse([454, 888, 570, 950], fill=white)

for cx, cy, r in [(150, 150, 18), (874, 130, 14), (130, 750, 12), (880, 740, 16)]:
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(255, 255, 255, 80))

img.save("C:/Dipti/jugaad_fix/assets/images/app_icon.png")
print("Icon saved!")

img2 = Image.open("C:/Dipti/jugaad_fix/assets/images/app_icon.png")
sizes = {"mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96, "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192}
for folder, s in sizes.items():
    resized = img2.resize((s, s), Image.LANCZOS)
    resized.save(f"C:/Dipti/jugaad_fix/android/app/src/main/res/{folder}/ic_launcher.png")
    print(f"Saved {folder}")

print("All icons done!")
