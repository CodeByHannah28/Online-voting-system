package com.bascode.util;

import com.bascode.model.enums.Position;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public final class PositionSupport {

    private PositionSupport() {
    }

    public static String format(Position position) {
        if (position == null) {
            return "Unassigned";
        }

        String[] words = position.name().toLowerCase(Locale.ENGLISH).split("_");
        StringBuilder label = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) {
                continue;
            }
            if (label.length() > 0) {
                label.append(' ');
            }
            label.append(Character.toUpperCase(word.charAt(0)));
            if (word.length() > 1) {
                label.append(word.substring(1));
            }
        }
        return label.toString();
    }

    public static Map<String, String> labels() {
        LinkedHashMap<String, String> labels = new LinkedHashMap<>();
        for (Position position : Position.values()) {
            labels.put(position.name(), format(position));
        }
        return Collections.unmodifiableMap(labels);
    }
}
