package com.quindioflix.repository;

import com.quindioflix.model.HistorialPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HistorialPlanRepository extends JpaRepository<HistorialPlan, Long> {
}

