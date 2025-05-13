import org.junit.Before;
import org.junit.Test;

import static junit.framework.Assert.assertTrue;
import static junit.framework.Assert.assertFalse;

public class PointHitTest {
    private CheckPointBean checkPointBean;

    @Before
    public void setUp() {
        checkPointBean = new CheckPointBean();
    }

    // Тесты для верхнего правого квадранта (x >= 0, y >= 0): y <= r - 2 * x
    @Test
    public void testPointHit_UpperRight_Hit() {
        boolean result = checkPointBean.pointHit(0.5, 0.5, 2.0);
        assertTrue("Point (0.5, 0.5) should hit with R=2", result);
    }

    @Test
    public void testPointHit_UpperRight_Miss() {
        boolean result = checkPointBean.pointHit(1.0, 1.0, 1.0);
        assertFalse("Point (1.0, 1.0) should miss with R=1", result);
    }

    @Test
    public void testPointHit_UpperRight_Border() {
        boolean result = checkPointBean.pointHit(0.5, 1.0, 2.0);
        assertTrue("Point (0.5, 1.0) on border should hit with R=2", result);
    }

    // Тесты для верхнего левого квадранта (x <= 0, y >= 0): y <= r && x >= -r
    @Test
    public void testPointHit_UpperLeft_Hit() {
        boolean result = checkPointBean.pointHit(-0.5, 0.5, 1.0);
        assertTrue("Point (-0.5, 0.5) should hit with R=1", result);
    }

    @Test
    public void testPointHit_UpperLeft_Miss_X() {
        boolean result = checkPointBean.pointHit(-1.5, 0.5, 1.0);
        assertFalse("Point (-1.5, 0.5) should miss with R=1 (x < -r)", result);
    }

    @Test
    public void testPointHit_UpperLeft_Miss_Y() {
        boolean result = checkPointBean.pointHit(-0.5, 1.5, 1.0);
        assertFalse("Point (-0.5, 1.5) should miss with R=1 (y > r)", result);
    }

    @Test
    public void testPointHit_UpperLeft_Border() {
        boolean result = checkPointBean.pointHit(-1.0, 1.0, 1.0);
        assertTrue("Point (-1.0, 1.0) on border should hit with R=1", result);
    }

    // Тесты для нижнего правого квадранта (x >= 0, y <= 0): x * x + y * y <= r/2 * r/2
    @Test
    public void testPointHit_LowerRight_Hit() {
        boolean result = checkPointBean.pointHit(0.25, -0.25, 1.0);
        assertTrue("Point (0.25, -0.25) should hit with R=1", result);
    }

    @Test
    public void testPointHit_LowerRight_Miss() {
        boolean result = checkPointBean.pointHit(0.5, -0.5, 1.0);
        assertFalse("Point (0.5, -0.5) should miss with R=1", result);
    }

    @Test
    public void testPointHit_LowerRight_Border() {
        boolean result = checkPointBean.pointHit(0.5, 0.0, 2.0);
        assertTrue("Point (0.5, 0.0) on border should hit with R=2", result);
    }

    // Тесты для нижнего левого квадранта (x < 0, y < 0): всегда false
    @Test
    public void testPointHit_LowerLeft_Miss() {
        boolean result = checkPointBean.pointHit(-0.5, -0.5, 1.0);
        assertFalse("Point (-0.5, -0.5) should miss with any R", result);
    }

    // Тесты для граничных случаев
    @Test
    public void testPointHit_ZeroRadius() {
        boolean result = checkPointBean.pointHit(0.0, 0.0, 0.0);
        assertTrue("Point (0.0, 0.0) should hit with R=0 (border case)", result);
    }

    @Test
    public void testPointHit_NegativeRadius() {
        boolean result = checkPointBean.pointHit(0.5, 0.5, -1.0);
        assertFalse("Point (0.5, 0.5) should miss with negative R", result);
    }
}
