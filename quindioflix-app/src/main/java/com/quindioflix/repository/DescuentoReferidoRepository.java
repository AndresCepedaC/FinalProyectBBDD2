package com.quindioflix.repository;

import com.quindioflix.model.DescuentoReferido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DescuentoReferidoRepository extends JpaRepository<DescuentoReferido, Long> {
}

