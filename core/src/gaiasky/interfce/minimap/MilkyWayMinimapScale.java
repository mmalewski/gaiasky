/*
 * This file is part of Gaia Sky, which is released under the Mozilla Public License 2.0.
 * See the file LICENSE.md in the project root for full license details.
 */

package gaiasky.interfce.minimap;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.FrameBuffer;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer.ShapeType;
import com.badlogic.gdx.math.Vector2;
import gaiasky.GaiaSky;
import gaiasky.scenegraph.camera.ICamera;
import gaiasky.util.Constants;
import gaiasky.util.I18n;
import gaiasky.util.color.ColourUtils;
import gaiasky.util.coord.Coordinates;
import gaiasky.util.math.Vector2d;
import gaiasky.util.math.Vector3d;

public class MilkyWayMinimapScale extends AbstractMinimapScale {
    private Vector2 sunPos;

    public MilkyWayMinimapScale() {
        super();
    }

    @Override
    public void update(){

    }

    @Override
    public boolean isActive(Vector3d campos) {
        return campos.len() > 50 * Constants.AU_TO_U;
    }

    @Override
    public void initialize(OrthographicCamera ortho, SpriteBatch sb, ShapeRenderer sr, BitmapFont font, int side, int sideshort) {
        super.initialize(ortho, sb, sr, font, side, sideshort, Constants.PC_TO_U, Constants.U_TO_PC, 16000, 100000 * Constants.AU_TO_U * Constants.U_TO_PC);
        trans = Coordinates.eqToGal();
        sunPos = new Vector2(u2Px(0, side2), u2Px(-8000, side2));
    }

    @Override
    public void renderSideProjection(FrameBuffer fb) {
        Gdx.gl.glEnable(GL20.GL_BLEND);

        ortho.setToOrtho(true, side, sideshort);
        sr.setProjectionMatrix(ortho.combined);
        sb.setProjectionMatrix(ortho.combined);
        fb.begin();
        // Clear
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT | GL20.GL_DEPTH_BUFFER_BIT | (Gdx.graphics.getBufferFormat().coverageSampling ? GL20.GL_COVERAGE_BUFFER_BIT_NV : 0));
        Gdx.gl.glBlendFunc(GL20.GL_SRC_ALPHA, GL20.GL_ONE_MINUS_SRC_ALPHA);

        ICamera cam = GaiaSky.instance.cam.current;
        // Position
        Vector3d pos = aux3d1.set(cam.getPos()).mul(trans);
        Vector2d campos2 = aux2d1;
        campos2.set(pos.z, pos.y).scl(Constants.U_TO_PC);
        campos2.x -= 8000;
        campos2.y *= side / sideshort;
        float cx = u2Px(campos2.x, side2);
        float cy = u2Px(campos2.y, sideshort2);
        // Direction
        Vector3d dir = aux3d2.set(cam.getDirection()).mul(trans);
        Vector2d camdir2 = aux2d2.set(dir.z, dir.y).nor().scl(px(15f));

        sr.begin(ShapeType.Filled);
        // Mw disk
        sr.setColor(0.15f, 0.15f, 0.35f, 1f);
        sr.ellipse(0, sideshort2 - side * 0.015f, side, side * 0.03f);
        // Mw bulge
        sr.setColor(0.05f, 0.05f, 0.2f, 1f);
        sr.circle(side2, sideshort2, side * 0.08f);

        // Camera
        sr.setColor(ColourUtils.gRedC);
        sr.circle(cx, cy, 8f);
        Vector2d endx = aux2d1.set(camdir2.x, camdir2.y);
        endx.rotate(-cam.getCamera().fieldOfView / 2d);
        float c1x = (float) endx.x + cx;
        float c1y = (float) endx.y + cy;
        endx.set(camdir2.x, camdir2.y);
        endx.rotate(cam.getCamera().fieldOfView / 2d);
        sr.triangle(cx, cy, c1x, c1y, (float) endx.x + cx, (float) endx.y + cy);

        // Camera span
        sr.setColor(1,1,1,0.1f);
        endx = aux2d1.set(camdir2.x, camdir2.y).scl(40f);
        endx.rotate(-cam.getCamera().fieldOfView / 2d);
        c1x = (float) endx.x + cx;
        c1y = (float) endx.y + cy;
        endx.set(camdir2.x, camdir2.y).scl(40f);
        endx.rotate(cam.getCamera().fieldOfView / 2d);
        sr.triangle(cx, cy, c1x, c1y, (float) endx.x + cx, (float) endx.y + cy);

        // Sun position, 8 Kpc to do galactocentric
        sr.setColor(1f, 1f, 0f, 1f);
        sr.circle(u2Px(-8000, side2), u2Px(0, sideshort2), px(2.5f));
        // GC
        sr.setColor(0f, 0f, 0f, 1f);
        sr.circle(u2Px(0, side2), u2Px(0, sideshort2), px(2.5f));
        sr.end();

        // Fonts
        sb.begin();
        font.setColor(1, 1, 0, 1);
        font.draw(sb, I18n.txt("gui.minimap.sun"), u2Px(-8000, side2), u2Px(0, sideshort2) - px(8));
        font.setColor(textc);
        font.draw(sb, I18n.txt("gui.minimap.gc"), side2, sideshort2 - px(4));
        sb.end();

        fb.end();

    }

    @Override
    public void renderTopProjection(FrameBuffer fb) {
        Gdx.gl.glEnable(GL20.GL_BLEND);

        ortho.setToOrtho(true, side, side);
        sr.setProjectionMatrix(ortho.combined);
        sb.setProjectionMatrix(ortho.combined);
        fb.begin();
        // Clear
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT | GL20.GL_DEPTH_BUFFER_BIT | (Gdx.graphics.getBufferFormat().coverageSampling ? GL20.GL_COVERAGE_BUFFER_BIT_NV : 0));
        Gdx.gl.glBlendFunc(GL20.GL_SRC_ALPHA, GL20.GL_ONE_MINUS_SRC_ALPHA);

        ICamera cam = GaiaSky.instance.cam.current;
        // Position
        Vector3d pos = aux3d1.set(cam.getPos()).mul(trans);
        Vector2d campos2 = aux2d1;
        campos2.set(pos.x, pos.z).scl(Constants.U_TO_PC);
        campos2.y -= 8000;
        float cx = u2Px(campos2.x, side2);
        float cy = u2Px(campos2.y, side2);
        // Direction
        Vector3d dir = aux3d2.set(cam.getDirection()).mul(trans);
        Vector2d camdir2 = aux2d2.set(dir.x, dir.z).nor().scl(px(15f));

        sr.begin(ShapeType.Filled);
        // Grid
        float col = 0.0f;
        for (int i = 16000; i >= 4000; i -= 4000) {
            sr.setColor(0.15f-col, 0.15f-col, 0.35f-col, 1f);
            sr.circle(side2, side2, i * side / 32000);
            col += 0.05f;
        }
        sr.circle(side2, side2, 1.5f);

        // Camera
        sr.setColor(ColourUtils.gRedC);
        sr.circle(cx, cy, 8f);
        Vector2d endx = aux2d1.set(camdir2.x, camdir2.y);
        endx.rotate(-cam.getCamera().fieldOfView / 2d);
        float c1x = (float) endx.x + cx;
        float c1y = (float) endx.y + cy;
        endx.set(camdir2.x, camdir2.y);
        endx.rotate(cam.getCamera().fieldOfView / 2d);
        sr.triangle(cx, cy, c1x, c1y, (float) endx.x + cx, (float) endx.y + cy);

        // Camera span
        sr.setColor(1,1,1,0.1f);
        endx = aux2d1.set(camdir2.x, camdir2.y).scl(40f);
        endx.rotate(-cam.getCamera().fieldOfView / 2d);
        c1x = (float) endx.x + cx;
        c1y = (float) endx.y + cy;
        endx.set(camdir2.x, camdir2.y).scl(40f);
        endx.rotate(cam.getCamera().fieldOfView / 2d);
        sr.triangle(cx, cy, c1x, c1y, (float) endx.x + cx, (float) endx.y + cy);

        // Sun position, 8 Kpc to do galactocentric
        sr.setColor(1f, 1f, 0f, 1f);
        sr.circle(sunPos.x, sunPos.y, px(2.5f));
        // GC
        sr.setColor(0f, 0f, 0f, 1f);
        sr.circle(side2, side2, px(2.5f));
        sr.end();

        // Fonts
        sb.begin();
        font.setColor(1, 1, 0, 1);
        font.draw(sb, I18n.txt("gui.minimap.sun"), side2, sunPos.y - px(8));
        font.setColor(textc);
        font.draw(sb, I18n.txt("gui.minimap.gc"), side2 + px(4), side2 - px(4));
        for (int i = 4000; i <= 16000; i += 4000) {
            font.draw(sb, "" + (i / 1000) + "Kpc", side2, (16000 + i) * side / 32000 - px(6));
        }
        sb.end();

        fb.end();

    }

}
