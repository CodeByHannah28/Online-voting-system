package com.bascode.model.entity;

import jakarta.persistence.*;

@Entity
@Table(
    name = "votes",
    uniqueConstraints = @UniqueConstraint(columnNames = "voter_id")
)
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "voter_id")
    private User voter;

    @ManyToOne
    private Contester contester;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public User getVoter() {
		return voter;
	}

	public void setVoter(User voter) {
		this.voter = voter;
	}

	public Contester getContester() {
		return contester;
	}

	public void setContester(Contester contester) {
		this.contester = contester;
	}
    
    
}
