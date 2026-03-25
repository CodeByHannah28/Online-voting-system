package com.bascode.model.entity;

import com.bascode.model.enums.Position;
import jakarta.persistence.*;

@Entity
@Table(
    name = "votes",
    uniqueConstraints = @UniqueConstraint(columnNames = {"voter_id", "position"})
)
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "voter_id")
    private User voter;

    @ManyToOne
    @JoinColumn(name = "contester_id")
    private Contester contester;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private Position position;

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

	public Position getPosition() {
		return position;
	}

	public void setPosition(Position position) {
		this.position = position;
	}

}
