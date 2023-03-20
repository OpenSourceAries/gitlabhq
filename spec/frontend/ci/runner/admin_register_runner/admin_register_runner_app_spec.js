import { nextTick } from 'vue';
import { GlButton } from '@gitlab/ui';

import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import setWindowLocation from 'helpers/set_window_location_helper';
import { TEST_HOST } from 'helpers/test_constants';

import { updateHistory } from '~/lib/utils/url_utility';
import { PARAM_KEY_PLATFORM, DEFAULT_PLATFORM, WINDOWS_PLATFORM } from '~/ci/runner/constants';
import AdminRegisterRunnerApp from '~/ci/runner/admin_register_runner/admin_register_runner_app.vue';
import RegistrationInstructions from '~/ci/runner/components/registration/registration_instructions.vue';
import PlatformsDrawer from '~/ci/runner/components/registration/platforms_drawer.vue';
import { runnerForRegistration } from '../mock_data';

const mockRunnerId = runnerForRegistration.data.runner.id;
const mockRunnersPath = '/admin/runners';

jest.mock('~/lib/utils/url_utility', () => ({
  ...jest.requireActual('~/lib/utils/url_utility'),
  updateHistory: jest.fn(),
}));

describe('AdminRegisterRunnerApp', () => {
  let wrapper;

  const findRegistrationInstructions = () => wrapper.findComponent(RegistrationInstructions);
  const findPlatformsDrawer = () => wrapper.findComponent(PlatformsDrawer);
  const findBtn = () => wrapper.findComponent(GlButton);

  const createComponent = () => {
    wrapper = shallowMountExtended(AdminRegisterRunnerApp, {
      propsData: {
        runnerId: mockRunnerId,
        runnersPath: mockRunnersPath,
      },
    });
  };

  describe('When showing runner details', () => {
    beforeEach(async () => {
      createComponent();
    });

    describe('when runner token is available', () => {
      it('shows registration instructions', () => {
        expect(findRegistrationInstructions().props()).toEqual({
          platform: DEFAULT_PLATFORM,
          runnerId: mockRunnerId,
        });
      });

      it('configures platform drawer', () => {
        expect(findPlatformsDrawer().props()).toEqual({
          open: false,
          platform: DEFAULT_PLATFORM,
        });
      });

      it('shows runner list button', () => {
        expect(findBtn().attributes('href')).toBe(mockRunnersPath);
        expect(findBtn().props('variant')).toBe('confirm');
      });
    });
  });

  describe('When another platform has been selected', () => {
    beforeEach(async () => {
      setWindowLocation(`?${PARAM_KEY_PLATFORM}=${WINDOWS_PLATFORM}`);

      createComponent();
    });

    it('shows registration instructions for the platform', () => {
      expect(findRegistrationInstructions().props('platform')).toBe(WINDOWS_PLATFORM);
    });
  });

  describe('When opening install instructions', () => {
    beforeEach(async () => {
      createComponent();

      findRegistrationInstructions().vm.$emit('toggleDrawer');
      await nextTick();
    });

    it('opens platform drawer', () => {
      expect(findPlatformsDrawer().props('open')).toBe(true);
    });

    it('closes platform drawer', async () => {
      findRegistrationInstructions().vm.$emit('toggleDrawer');
      await nextTick();

      expect(findPlatformsDrawer().props('open')).toBe(false);
    });

    it('closes platform drawer from drawer', async () => {
      findPlatformsDrawer().vm.$emit('close');
      await nextTick();

      expect(findPlatformsDrawer().props('open')).toBe(false);
    });

    describe('when selecting a platform', () => {
      beforeEach(async () => {
        findPlatformsDrawer().vm.$emit('selectPlatform', WINDOWS_PLATFORM);
        await nextTick();
      });

      it('updates the url', () => {
        expect(updateHistory).toHaveBeenCalledTimes(1);
        expect(updateHistory).toHaveBeenCalledWith({
          url: `${TEST_HOST}/?${PARAM_KEY_PLATFORM}=${WINDOWS_PLATFORM}`,
        });
      });

      it('updates the registration instructions', () => {
        expect(findRegistrationInstructions().props('platform')).toBe(WINDOWS_PLATFORM);
      });
    });
  });
});
