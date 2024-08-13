import { GlTable } from '@gitlab/ui';
import Vue from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import BadgeSettings from '~/badges/components/badge_settings.vue';
import BadgeList from '~/badges/components/badge_list.vue';
import BadgeForm from '~/badges/components/badge_form.vue';
import store from '~/badges/store';
import { createDummyBadge } from '../dummy_badge';

Vue.use(Vuex);

describe('BadgeSettings component', () => {
  let wrapper;
  const badge = createDummyBadge();

  const createComponent = (isEditing = false) => {
    store.state.badges = [badge];
    store.state.kind = 'project';
    store.state.isEditing = isEditing;

    wrapper = shallowMountExtended(BadgeSettings, {
      store,
      stubs: {
        CrudComponent,
        GlTable,
        'badge-list': BadgeList,
        'badge-form': BadgeForm,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  it('renders a header with the badge count', () => {
    createComponent();
    const cardTitle = wrapper.findByTestId('crud-title');
    const cardCount = wrapper.findByTestId('crud-count');

    expect(cardTitle.text()).toContain('Your badges');
    expect(cardCount.text()).toContain('1');
  });

  it('displays a table', () => {
    expect(wrapper.findComponent(GlTable).isVisible()).toBe(true);
  });

  it('renders badge add form', () => {
    expect(wrapper.findComponent(BadgeForm).exists()).toBe(true);
  });

  it('renders badge list', () => {
    expect(wrapper.findComponent(BadgeList).isVisible()).toBe(true);
  });

  describe('when editing', () => {
    beforeEach(() => {
      createComponent({ isEditing: true });
    });

    it('displays a form to edit a badge', () => {
      expect(wrapper.find('[data-testid="edit-badge"]').isVisible()).toBe(true);
    });
  });
});
