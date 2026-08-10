import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { StateLegend } from './state-badge';

describe('epistemic state legend', () => {
  it('visually and textually distinguishes the four portal knowledge states', () => {
    render(<StateLegend />);
    expect(screen.getByText('AI SUGGESTION')).toHaveClass('state-ai-suggestion');
    expect(screen.getByText('INTERPRETATION')).toHaveClass('state-interpretation');
    expect(screen.getByText('VALIDATED INSIGHT')).toHaveClass('state-validated-insight');
    expect(screen.getByText('DECISION')).toHaveClass('state-decision');
    expect(screen.getByText(/Suggestions invite review/)).toBeInTheDocument();
  });
});
