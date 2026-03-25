package com.bascode.util;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;

public final class ContesterSupport {

    private ContesterSupport() {
    }

    public static Contester newPendingApplication(User user) {
        Contester contester = new Contester();
        contester.setUser(user);
        contester.setStatus(ContesterStatus.PENDING);
        return contester;
    }

    public static boolean hasSelectedPosition(Contester contester) {
        return contester != null && contester.getPosition() != null;
    }
}
