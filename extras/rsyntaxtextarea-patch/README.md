# RSyntaxTextArea 3.3.4 line wrap patch

JMeter 5.6.3 ships `lib/rsyntaxtextarea-3.3.4.jar`. With line wrap on (`jsyntaxtextarea.linewrap=true`,
the default) wrapping a long token is quadratic in the token length: for every wrapped row
`WrappedSyntaxView.calculateBreakPosition` measures the width of the whole remaining token, and
`TokenUtils.getSubTokenList` measures almost the whole tail of it as well. Opening an HTTP sampler with
a 200 KB single-line body (one ~160 KB token) froze the GUI for ~10 s.

The patch:

- `WrappedSyntaxView.calculateBreakPosition`: looks for the overflow with `getOffsetBeforeX()`, which stops
  at the end of the row, and measures the full token width only when the token fits.
- `TokenUtils.getSubTokenList`: the x offset of `pos` is the width of the `difference` chars before it
  (was `t.length()-difference+1` chars). This x is only used for tab stops of wrapped continuation rows.

Wrap break positions are unchanged for texts without tabs. The same code is in RSyntaxTextArea 4.0.1.

Build and install:

    ./build.sh /tmp/rsyntaxtextarea-3.3.4.jar
    cp /tmp/rsyntaxtextarea-3.3.4.jar ~/.sdkman/candidates/jmeter/5.6.3-perf/lib/rsyntaxtextarea-3.3.4.jar
