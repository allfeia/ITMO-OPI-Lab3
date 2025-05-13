import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import java.io.Serializable;
import java.util.Locale;

@ManagedBean(name = "languageBean")
@SessionScoped
public class LanguageBean implements Serializable {

    private Locale currentLocale;

    public LanguageBean() {
        this.currentLocale = FacesContext.getCurrentInstance().getExternalContext().getRequestLocale();
    }

    public Locale getCurrentLocale() {
        return currentLocale;
    }

    public void setCurrentLocale(Locale currentLocale) {
        this.currentLocale = currentLocale;
    }

    public void changeLanguage(String language) {
        System.out.println("Changing language to: " + language);
        currentLocale = new Locale(language);
        FacesContext.getCurrentInstance().getViewRoot().setLocale(currentLocale);
        System.out.println("New locale: " + currentLocale);
    }
}