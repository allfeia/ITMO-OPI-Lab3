import db.PointDAO;
import db.PointModel;
import org.primefaces.PrimeFaces;

import javax.faces.bean.ApplicationScoped;
import javax.faces.bean.ManagedBean;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@ManagedBean(name = "checkPointBean")
@ApplicationScoped
public class CheckPointBean implements Serializable {
    static DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private boolean isHit;
    private PointDAO pointDAO = new PointDAO();
    private List<PointModel> results = (List<PointModel>) pointDAO.findLastFive();

    private int currentPage = 0;
    private int pageSize = 5;
    private int totalPages;

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
        updateTotalPages();

    }

    public List<PointModel> getResults() {
        return getResultsByPage(currentPage, pageSize);
    }

    public void setResults(List<PointModel> results) {
        this.results = results;
        updateTotalPages();
    }

    public boolean getIsHit() {
        return isHit;
    }

    public void setIsHit(boolean hit) {
        isHit = hit;
    }

    public void check(PointBean pointBean) {
        long startTime = System.nanoTime();

        isHit = pointHit(pointBean.getX(), pointBean.getY(), pointBean.getR());
        PrimeFaces.current().executeScript("drawPoint(" + pointBean.getX() + "," + pointBean.getY() + "," + pointBean.getR() + "," + isHit + ")");

        PointModel pointModel = new PointModel(pointBean.getX(), pointBean.getY(), pointBean.getR(), isHit, String.valueOf(System.nanoTime() - startTime), formatter.format(LocalDateTime.now()));
        results.add(0, pointModel);
        pointDAO.savePoint(pointModel);

        updateTotalPages();

    }

    public boolean pointHit(double x, double y, double r) {
        if (x < 0 && y < 0) return false;
        else if (x >= 0 && y >= 0) return y <= r - 2 * x;
        else if (x <= 0 && y >= 0) return y <= r && x >= -r;
        else return x * x + y * y <= r/2 * r/2;
    }

    public List<PointModel> getResultsByPage(int page, int pageSize) {
        int fromIndex = page * pageSize;
        int toIndex = Math.min((page + 1) * pageSize, results.size());

        if (fromIndex >= results.size()) {
            return new ArrayList<>();
        }
        return results.subList(fromIndex, toIndex);
    }

    public void previousPage() {
        if (currentPage > 0) {
            currentPage--;
        }
    }

    public void nextPage() {
        if (currentPage < totalPages - 1) {
            currentPage++;
        }
    }

    private void updateTotalPages() {
        totalPages = (int) Math.ceil((double) results.size() / pageSize);
    }

    public int getTotalPages() {
        return totalPages;
    }

}