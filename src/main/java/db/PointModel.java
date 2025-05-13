package db;

import jakarta.persistence.*;

@Entity
@Table(name = "points")
public class PointModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private double x;
    private double y;
    private double r;
    private boolean is_hit;
    private String server_time;
    private String execution_time;

    public PointModel(double x, double y, double r, boolean is_hit, String executionTime, String serverTime) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.is_hit = is_hit;
        this.execution_time = executionTime;
        this.server_time = serverTime;
    }

    public PointModel() {
    }

    public double getX() {
        return x;
    }

    public void setX(double x) {
        this.x = x;
    }

    public double getY() {
        return y;
    }

    public void setY(double y) {
        this.y = y;
    }

    public double getR() {
        return r;
    }

    public void setR(double r) {
        this.r = r;
    }

    public boolean getIsHit() { return is_hit; }
    public void setIsHit(boolean isHit) { this.is_hit = is_hit; }


    public String getServer_time() {
        return server_time;
    }

    public void setServer_time(String server_time) {
        this.server_time = server_time;
    }

    public String getExecution_time() {
        return execution_time;
    }

    public void setExecution_time(String execution_time) {
        this.execution_time = execution_time;
    }
}

