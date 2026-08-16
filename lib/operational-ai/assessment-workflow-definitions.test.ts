import { describe, expect, it } from 'vitest';
import { assessmentDefinitionForDatabase, assessmentWorkflowDefinitions, getAssessmentWorkflowDefinition } from './assessment-workflow-definitions';

describe('authoritative assessment workflow definitions', () => {
  it('preserves the complete section and item structures from both source worksheets', () => {
    const leadership = getAssessmentWorkflowDefinition('mission-product-automation-leadership-assessment');
    const workflow = getAssessmentWorkflowDefinition('mission-product-workflow-and-automation-assessment');

    expect([leadership?.sections.length, leadership?.items.length]).toEqual([9, 36]);
    expect([workflow?.sections.length, workflow?.items.length]).toEqual([12, 48]);
    expect(leadership?.items.some((item) => item.itemKey === 'LEAD_AUTHORITY_MATRIX' && item.response.uiType === 'matrix')).toBe(true);
    expect(workflow?.items.some((item) => item.itemKey === 'WORKFLOW_STEPS' && item.response.uiType === 'matrix')).toBe(true);
    expect(workflow?.items.some((item) => item.prompt === '7.4  Which parts should never be generated, decided, released, or transmitted by automation? Why?')).toBe(true);
  });

  it('uses stable unique item keys and no autonomous scoring rule', () => {
    for (const definition of assessmentWorkflowDefinitions) {
      expect(new Set(definition.items.map((item) => item.itemKey)).size).toBe(definition.items.length);
      const projected = assessmentDefinitionForDatabase(definition);
      expect(projected.items).toHaveLength(definition.items.length);
      expect(projected.items.every((item) => item.responseOptions.guidance && item.responseOptions.uiType)).toBe(true);
    }
  });
});
