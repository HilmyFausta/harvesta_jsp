package com.harvesta;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Initializing Harvesta...");
        Db.init();
        Seeder.run();
        System.out.println("Harvesta initialized successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        Db.close();
        System.out.println("Harvesta shutdown.");
    }
}
