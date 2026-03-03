package com.bascode.model.entity;

import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;

import jakarta.persistence.*;

@Entity
@Table(name = "contesters")
public class Contester {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    private User user;

    @Enumerated(EnumType.STRING)
    private Position position;

    @Enumerated(EnumType.STRING)
    private ContesterStatus status;

    
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public Position getPosition() {
		return position;
	}

	public void setPosition(Position position) {
		this.position = position;
	}

	public ContesterStatus getStatus() {
		return status;
	}

	public void setStatus(ContesterStatus status) {
		this.status = status;
	}
    
    
}
