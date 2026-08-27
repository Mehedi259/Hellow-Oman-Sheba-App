from PIL import Image, ImageDraw, ImageFont
import os

logo_path = 'assets/images/main-logo.png'
out_dir = 'play_store_assets'
os.makedirs(out_dir, exist_ok=True)

# 1. Generate App Icon (512x512)
try:
    logo = Image.open(logo_path).convert("RGBA")
    
    # Calculate aspect ratio
    logo_w, logo_h = logo.size
    aspect = logo_w / logo_h
    
    # We want to fit the logo inside a 512x512 square with some padding
    # Let's say max width or height is 400
    if logo_w > logo_h:
        new_w = 400
        new_h = int(new_w / aspect)
    else:
        new_h = 400
        new_w = int(new_h * aspect)
        
    logo_resized = logo.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Create white 512x512 background
    icon_bg = Image.new('RGB', (512, 512), (255, 255, 255))
    
    # Paste logo in center
    offset_x = (512 - new_w) // 2
    offset_y = (512 - new_h) // 2
    
    # Use alpha channel as mask for transparent logos
    icon_bg.paste(logo_resized, (offset_x, offset_y), logo_resized)
    
    icon_path = os.path.join(out_dir, 'app_icon_512.png')
    icon_bg.save(icon_path, 'PNG')
    print(f"Created {icon_path}")
    
except Exception as e:
    print(f"Error creating icon: {e}")

# 2. Generate Feature Graphic (1024x500)
try:
    feature_w, feature_h = 1024, 500
    
    # Create a nice gradient background (blue to purple, matching the app's hero banner)
    # The app uses Color(0xFF2563EB) to Color(0xFF9333EA)
    color1 = (37, 99, 235) # 0xFF2563EB
    color2 = (147, 51, 234) # 0xFF9333EA
    
    feature_bg = Image.new('RGB', (feature_w, feature_h))
    draw = ImageDraw.Draw(feature_bg)
    
    for x in range(feature_w):
        # Calculate intermediate color for each column (left to right)
        r = int(color1[0] + (color2[0] - color1[0]) * (x / feature_w))
        g = int(color1[1] + (color2[1] - color1[1]) * (x / feature_w))
        b = int(color1[2] + (color2[2] - color1[2]) * (x / feature_w))
        draw.line([(x, 0), (x, feature_h)], fill=(r, g, b))
        
    # Resize logo for feature graphic (let's make it relatively large)
    # We can center the logo on the feature graphic
    if logo_w > logo_h:
        feat_logo_w = 400
        feat_logo_h = int(feat_logo_w / aspect)
    else:
        feat_logo_h = 350
        feat_logo_w = int(feat_logo_h * aspect)
        
    logo_feat = logo.resize((feat_logo_w, feat_logo_h), Image.Resampling.LANCZOS)
    
    # Paste logo in center
    feat_offset_x = (feature_w - feat_logo_w) // 2
    feat_offset_y = (feature_h - feat_logo_h) // 2
    
    # We could also draw a white rounded rectangle behind the logo to make it pop
    # But since we don't know if the logo has text that might clash, let's just create a white pill/circle or use the logo directly if it's transparent.
    # Often, just a clean white background version looks very professional. 
    # Wait, the app's main logo might have dark text which is hard to read on a dark blue/purple gradient!
    # Let's put a white rounded rectangle behind the logo.
    
    padding = 40
    rect_x0 = feat_offset_x - padding
    rect_y0 = feat_offset_y - padding
    rect_x1 = feat_offset_x + feat_logo_w + padding
    rect_y1 = feat_offset_y + feat_logo_h + padding
    
    draw.rounded_rectangle([rect_x0, rect_y0, rect_x1, rect_y1], radius=24, fill=(255, 255, 255))
    
    # Paste logo
    feature_bg.paste(logo_feat, (feat_offset_x, feat_offset_y), logo_feat)
    
    feature_path = os.path.join(out_dir, 'feature_graphic_1024x500.png')
    feature_bg.save(feature_path, 'PNG')
    print(f"Created {feature_path}")

except Exception as e:
    print(f"Error creating feature graphic: {e}")

